module Ethernet_tx (
    input wire clk,                  // Clock signal
    input wire rst,                  // Reset signal
    input wire tx_start,             // Signal to start transmission
    input wire [7:0] tx_data_in,     // Input data to be transmitted
    input wire tx_data_valid,        // Signal indicating valid input data
    output reg tx_ready,             // Signal indicating transmitter is ready for new data
    output reg tx_done,              // Signal indicating transmission is complete
    output reg [7:0] tx_data_out,    // Output data being transmitted
    input wire [47:0] src_mac,       // Source MAC address for the Ethernet frame
    input wire [47:0] dest_mac       // Destination MAC address for the Ethernet frame
);
    // Internal registers for the transmission process
    reg [7:0] tx_buffer [0:1518];    // Buffer to store the data to be transmitted (maximum frame size 1518 bytes)
    reg [31:0] tx_index;             // Index to keep track of position in the buffer during transmission
    reg [31:0] tx_length;            // Length of the Ethernet frame being transmitted
    reg [1:0] tx_state;              // State machine for controlling transmission process

    reg [31:0] crc_calculated;       // Register to hold the calculated CRC value during transmission

    // State machine states
    parameter IDLE = 2'b00;          // Idle state, waiting for transmission to start
    parameter TRANSMIT = 2'b01;      // Transmitting state, sending data

    // CRC-32 calculation function (using 0xA4C11DB7 polynomial)
    function [31:0] crc32;
        input [31:0] crc_in;       // Input CRC value from previous byte calculation
        input [7:0] data;          // Current byte of data to process
        reg [31:0] crc;            // Register for the CRC result
        integer i;                 // Loop variable for bit processing
        begin
            // XOR the incoming CRC value with the current byte of data
            crc = crc_in ^ {24'b0, data};
            // Process the CRC bits
            for (i = 0; i < 8; i = i + 1) begin
                // If the MSB of the CRC is 1, shift and XOR with the polynomial
                if (crc[31] == 1) begin
                    crc = (crc << 1) ^ 32'hA4C11DB7; // Polynomial 0xA4C11DB7 for CRC32
                end else begin
                    crc = crc << 1;  // Just shift left if MSB is 0
                end
            end
            crc32 = crc;  // Return the calculated CRC
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers and states on reset signal
            tx_state <= IDLE;          // Set state to IDLE
            tx_done <= 0;              // Transmission is not done
            tx_ready <= 1;             // Ready to transmit new data
            tx_index <= 0;             // Reset buffer index
            tx_length <= 0;            // Reset frame length
            tx_data_out <= 8'b0;       // Clear output data
            crc_calculated <= 32'hFFFFFFFF;  // Initialize CRC with initial value for CRC-32
        end else begin
            case (tx_state)
                IDLE: begin
                    tx_done <= 0;  // Transmission is not done in IDLE state
                    if (tx_start) begin
                        // Insert destination MAC address into the buffer
                        tx_buffer[0] <= dest_mac[47:40];
                        tx_buffer[1] <= dest_mac[39:32];
                        tx_buffer[2] <= dest_mac[31:24];
                        tx_buffer[3] <= dest_mac[23:16];
                        tx_buffer[4] <= dest_mac[15:8];
                        tx_buffer[5] <= dest_mac[7:0];

                        // Insert source MAC address into the buffer
                        tx_buffer[6] <= src_mac[47:40];
                        tx_buffer[7] <= src_mac[39:32];
                        tx_buffer[8] <= src_mac[31:24];
                        tx_buffer[9] <= src_mac[23:16];
                        tx_buffer[10] <= src_mac[15:8];
                        tx_buffer[11] <= src_mac[7:0];

                        tx_length <= 12;  // Set initial length to MAC address length (12 bytes)
                        tx_index <= 0;    // Reset buffer index
                        crc_calculated <= 32'hFFFFFFFF; // Initialize CRC calculation with initial value
                        tx_state <= TRANSMIT;  // Transition to TRANSMIT state
                        tx_ready <= 0;    // Indicate that transmitter is not ready until transmission begins
                    end
                end

                TRANSMIT: begin
                    if (tx_data_valid) begin
                        // Store incoming data into the buffer and calculate CRC
                        tx_buffer[tx_length] <= tx_data_in;
                        crc_calculated <= crc32(crc_calculated, tx_data_in);  // Update CRC calculation with current byte
                        tx_length <= tx_length + 1;  // Increment the length of the transmitted frame
                    end else if (tx_index < tx_length) begin
                        // Send the data byte by byte
                        tx_data_out <= tx_buffer[tx_index];  // Output current data byte for transmission
                        tx_index <= tx_index + 1;           // Move to the next byte in the buffer
                        tx_ready <= 0;                      // Indicate that transmitter is busy
                    end else begin
                        // Append the calculated CRC at the end of the frame
                        tx_buffer[tx_length] <= crc_calculated[31:24];
                        tx_buffer[tx_length + 1] <= crc_calculated[23:16];
                        tx_buffer[tx_length + 2] <= crc_calculated[15:8];
                        tx_buffer[tx_length + 3] <= crc_calculated[7:0];
                        tx_length <= tx_length + 4;  // Increase length by 4 bytes for CRC

                        tx_done <= 1;      // Indicate that the transmission is complete
                        tx_state <= IDLE;  // Go back to IDLE state, ready for the next transmission
                        tx_ready <= 1;     // Indicate that the transmitter is ready for new data
                    end
                end
            endcase
        end
    end
endmodule
/*
module Ethernet_tx (
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data_in,
    input wire tx_data_valid,
    output reg tx_ready,
    output reg tx_done,
    output reg [7:0] tx_data_out,
    input wire [47:0] src_mac,
    input wire [47:0] dest_mac
);
    reg [7:0] tx_buffer [0:1518];
    reg [31:0] tx_index;
    reg [31:0] tx_length;
    reg [1:0] tx_state;

    // State definitions
    parameter IDLE = 2'b00;
    parameter TRANSMIT = 2'b01;

    // CRC calculation (CRC-32: 0x04C11DB7 polynomial)
    function [31:0] crc32;
        input [31:0] crc_in;
        input [7:0] data;
        reg [31:0] crc;
        integer i;
        begin
            crc = crc_in ^ {24'b0, data};
            for (i = 0; i < 8; i = i + 1) begin
                if (crc[31] == 1) begin
                    crc = (crc << 1) ^ 32'h04C11DB7;
                end else begin
                    crc = crc << 1;
                end
            end
            crc32 = crc;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_state <= IDLE;
            tx_done <= 0;
            tx_ready <= 1;
            tx_index <= 0;
            tx_length <= 0;
            tx_data_out <= 8'b0;
        end else begin
            case (tx_state)
                IDLE: begin
                    tx_done <= 0;
                    if (tx_start) begin
                        // Insert destination MAC address
                        tx_buffer[0] <= dest_mac[47:40];
                        tx_buffer[1] <= dest_mac[39:32];
                        tx_buffer[2] <= dest_mac[31:24];
                        tx_buffer[3] <= dest_mac[23:16];
                        tx_buffer[4] <= dest_mac[15:8];
                        tx_buffer[5] <= dest_mac[7:0];

                        // Insert source MAC address
                        tx_buffer[6] <= src_mac[47:40];
                        tx_buffer[7] <= src_mac[39:32];
                        tx_buffer[8] <= src_mac[31:24];
                        tx_buffer[9] <= src_mac[23:16];
                        tx_buffer[10] <= src_mac[15:8];
                        tx_buffer[11] <= src_mac[7:0];

                        tx_length <= 12;  // MAC address length
                        tx_index <= 0;
                        tx_state <= TRANSMIT;
                        tx_ready <= 0;
                    end
                end
                TRANSMIT: begin
                    if (tx_data_valid) begin
                        tx_buffer[tx_length] <= tx_data_in;
                        tx_length <= tx_length + 1;
                    end else if (tx_index < tx_length) begin
                        tx_data_out <= tx_buffer[tx_index];
                        tx_index <= tx_index + 1;
                        tx_ready <= 0;
                    end else begin
                        tx_done <= 1;
                        tx_state <= IDLE;
                        tx_ready <= 1;
                    end
                end
            endcase
        end
    end
endmodule
*/