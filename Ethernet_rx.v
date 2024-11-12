




module Ethernet_rx ( 
    input wire clk,               // Clock signal
    input wire rst,               // Reset signal
    input wire rx_data_valid,     // Signal indicating valid incoming data
    input wire [7:0] rx_data_in,  // 8-bit incoming data
    output reg rx_data_ready,     // Signal indicating data is ready for further processing
    output reg [7:0] rx_data_out, // Output the received data byte
    output reg rx_done,           // Signal indicating reception is complete
    input wire [47:0] src_mac,    // Source MAC address
    input wire [47:0] dest_mac    // Destination MAC address
);

    // Internal signals and registers
    reg [7:0] rx_buffer [0:1518];  // Buffer to store the received frame (maximum 1518 bytes)
    reg [31:0] rx_index;           // Index for the current byte being received
    reg [31:0] rx_length;          // Length of the received frame
    reg [1:0] rx_state;            // State machine for the reception process
    reg [31:0] crc_received;       // Store the CRC value received with the frame
    reg [31:0] crc_calculated;     // Store the CRC calculated during reception

    // State definitions for the receiver's state machine
    parameter IDLE = 2'b00;        // IDLE state: waiting for valid data
    parameter RECEIVE = 2'b01;     // RECEIVE state: storing the incoming data
    parameter CRC_CHECK = 2'b10;   // CRC_CHECK state: verifying the received CRC

    // CRC calculation function (CRC-32: 0xA4C11DB7 polynomial)
    function [31:0] crc32;
        input [31:0] crc_in;       // Input CRC value
        input [7:0] data;          // Current byte of data
        reg [31:0] crc;            // Temporary CRC register
        integer i;
        begin
            // XOR incoming data with current CRC value
            crc = crc_in ^ {24'b0, data};
            // Perform 8-bit shifts and polynomial division
            for (i = 0; i < 8; i = i + 1) begin
                if (crc[31] == 1) begin
                    // Shift and apply the CRC-32 polynomial (0xA4C11DB7)
                    crc = (crc << 1) ^ 32'hA4C11DB7;
                end else begin
                    // Shift CRC left by one bit
                    crc = crc << 1;
                end
            end
            crc32 = crc;  // Return the updated CRC value
        end
    endfunction

    // Always block to control the receiver's behavior
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all registers and signals when reset is active
            rx_state <= IDLE;
            rx_done <= 0;
            rx_data_ready <= 0;
            rx_index <= 0;
            rx_length <= 0;
            rx_data_out <= 8'b0;
            crc_received <= 32'b0;
            crc_calculated <= 32'b0;
        end else begin
            // State machine for receiving data
            case (rx_state)
                IDLE: begin
                    rx_done <= 0;  // Clear rx_done signal
                    if (rx_data_valid) begin
                        // If valid data is available, start receiving
                        rx_state <= RECEIVE;
                        rx_index <= 0;
                        crc_calculated <= 32'hFFFFFFFF; // Initialize CRC (preliminary value for CRC-32)
                    end
                end

                RECEIVE: begin
                    if (rx_data_valid) begin
                        // Store the incoming data in the buffer and calculate CRC simultaneously
                        rx_buffer[rx_index] <= rx_data_in;  // Store the incoming byte in buffer
                        crc_calculated <= crc32(crc_calculated, rx_data_in);  // Update the CRC calculation
                        rx_data_out <= rx_data_in;  // Output the received byte
                        rx_index <= rx_index + 1;  // Increment index
                        rx_length <= rx_length + 1; // Increment the length of the received frame

                        // After receiving the frame data, check the CRC
                        if (rx_index >= rx_length - 4) begin
                            rx_state <= CRC_CHECK;  // Transition to CRC check state
                            // Extract the CRC value from the last 4 bytes of the buffer
                            crc_received <= {rx_buffer[rx_length-4], rx_buffer[rx_length-3], rx_buffer[rx_length-2], rx_buffer[rx_length-1]};
                        end
                    end
                end

                CRC_CHECK: begin
                    // Compare the received CRC with the calculated CRC
                    if (crc_received == crc_calculated) begin
                        rx_data_ready <= 1;  // If CRC matches, data is valid and ready
                        rx_done <= 1;        // Signal that the reception is complete
                    end else begin
                        rx_data_ready <= 0;  // If CRC doesn't match, data is invalid
                        rx_done <= 1;        // Still signal that reception is complete
                    end
                    rx_state <= IDLE;  // Return to IDLE state after checking CRC
                end
            endcase
        end
    end
endmodule


/*
module Ethernet_rx (
    input wire clk,
    input wire rst,
    input wire rx_data_valid,
    input wire [7:0] rx_data_in,
    output reg rx_data_ready,
    output reg [7:0] rx_data_out,
    output reg rx_done,
    input wire [47:0] src_mac,
    input wire [47:0] dest_mac
);
    reg [7:0] rx_buffer [0:1518];
    reg [31:0] rx_index;
    reg [31:0] rx_length;
    reg [1:0] rx_state;
    reg [31:0] crc_received; // Store the CRC from the received frame
    reg [31:0] crc_calculated; // Store the CRC calculated during reception

    // State definitions
    parameter IDLE = 2'b00;
    parameter RECEIVE = 2'b01;
    parameter CRC_CHECK = 2'b10;

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
            rx_state <= IDLE;
            rx_done <= 0;
            rx_data_ready <= 0;
            rx_index <= 0;
            rx_length <= 0;
            rx_data_out <= 8'b0;
            crc_received <= 32'b0;
            crc_calculated <= 32'b0;
        end else begin
            case (rx_state)
                IDLE: begin
                    rx_done <= 0;
                    if (rx_data_valid) begin
                        // Start receiving data
                        rx_state <= RECEIVE;
                        rx_index <= 0;
                        crc_calculated <= 32'hFFFFFFFF; // Initialize CRC calculation (preliminary value for CRC-32)
                    end
                end

                RECEIVE: begin
                    if (rx_data_valid) begin
                        // Store incoming data in buffer and calculate CRC
                        rx_buffer[rx_index] <= rx_data_in;
                        crc_calculated <= crc32(crc_calculated, rx_data_in);
                        rx_data_out <= rx_data_in;
                        rx_index <= rx_index + 1;
                        rx_length <= rx_length + 1;

                        // After receiving the entire frame, move to CRC check
                        if (rx_index >= rx_length - 4) begin
                            rx_state <= CRC_CHECK;
                            crc_received <= {rx_buffer[rx_length-4], rx_buffer[rx_length-3], rx_buffer[rx_length-2], rx_buffer[rx_length-1]};
                        end
                    end
                end

                CRC_CHECK: begin
                    // Check if received CRC matches the calculated CRC
                    if (crc_received == crc_calculated) begin
                        rx_data_ready <= 1; // Valid frame
                        rx_done <= 1;
                    end else begin
                        rx_data_ready <= 0; // Invalid frame
                        rx_done <= 1;
                    end
                    rx_state <= IDLE;
                end
            endcase
        end
    end
endmodule
*/