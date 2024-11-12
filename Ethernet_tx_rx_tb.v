`timescale 10ns / 100ps  // Define time unit (10ns) and time precision (100ps)

module Ethernet_tx_rx_tb;  // Testbench module for the Ethernet_tx_rx

    // Declare signals for the testbench
    reg clk;                   // Clock signal
    reg rst;                   // Reset signal
    reg tx_start;              // Start transmission signal
    reg [7:0] tx_data_in;     // Data input for transmission (8 bits)
    reg tx_data_valid;        // Indicates if the data is valid for transmission
    wire tx_ready;            // Output signal that indicates transmitter readiness
    wire tx_done;             // Output signal that indicates transmission completion
    wire [7:0] tx_data_out;  // Data output after transmission
    wire [7:0] rx_data_out;  // Data output after reception
    wire rx_data_valid;      // Indicates if received data is valid
    reg rx_data_ready;       // Input signal that indicates receiver readiness for data

    reg [47:0] src_mac;      // Source MAC address (48 bits)
    reg [47:0] dest_mac;     // Destination MAC address (48 bits)

    // Instantiate the top-level Ethernet module (Ethernet_tx_rx)
    Ethernet_tx_rx uut (
        .clk(clk),                    // Connect the clock signal
        .rst(rst),                    // Connect the reset signal
        .tx_start(tx_start),          // Start transmission signal
        .tx_data_in(tx_data_in),     // Transmit data input
        .tx_data_valid(tx_data_valid), // Transmit data valid signal
        .tx_ready(tx_ready),          // Transmit ready signal
        .tx_done(tx_done),            // Transmit done signal
        .tx_data_out(tx_data_out),   // Transmit data output
        .rx_data_out(rx_data_out),   // Received data output
        .rx_data_valid(rx_data_valid), // Received data valid signal
        .rx_data_ready(rx_data_ready), // Receiver ready signal
        .src_mac(src_mac),            // Source MAC address
        .dest_mac(dest_mac)           // Destination MAC address
    );

    // Clock generation: This generates a clock with a period of 10ns (100MHz frequency)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5ns to generate a 10ns period (100 MHz)
    end

    integer i;  // Integer for looping through test sequences

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;                     // Assert reset signal
        tx_start = 0;                // Set transmission start to 0 (not starting yet)
        tx_data_in = 0;              // Initialize transmit data to 0
        tx_data_valid = 0;           // Initialize transmit data valid to 0 (invalid data initially)
        rx_data_ready = 0;           // Receiver not ready initially

        src_mac = 48'h112233445566;  // Example source MAC address
        dest_mac = 48'hAABBCCDDEEFF; // Example destination MAC address

        // Reset the system: Apply reset for 20ns and then de-assert it
        #20 rst = 0;                 // Apply reset for 20ns
        #10;                         // Wait for some time after reset de-assertion

        // Begin transmission
        tx_start = 1;                // Trigger the transmission start
        #10;                         // Wait for 10ns
        tx_start = 0;                // De-assert transmission start

        // Transmit a frame payload (example data bytes 0xBA, 0xBB, ..., 0xCA)
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);              // Wait for the next clock edge
            tx_data_in = i + 8'hBA;     // Assign data to tx_data_in, starting from 0xBA
            tx_data_valid = 1;          // Mark the data as valid for transmission
            #10;                         // Wait for 10ns
        end
        tx_data_valid = 0;             // Mark data as invalid after the transmission

        // Wait for the transmission to complete, signaled by tx_done
        @(posedge tx_done);
        $display("Transmission complete."); // Print transmission completion message

        // Enable data reception by setting rx_data_ready to 1
        rx_data_ready = 1;            // Indicate that the receiver is ready to receive data

        // Monitor the received data
        i = 0;
        while (i < 16) begin
            @(posedge clk);              // Wait for the next clock cycle
            if (rx_data_valid) begin    // If received data is valid
                $display("Received data byte %0d: %h", i, rx_data_out); // Display the received byte
                i = i + 1;              // Increment the data byte counter
            end
        end

        // End the simulation after the verification of all received data
        #100;
        $display("Test complete.");    // Print test completion message
        $stop;                        // Stop the simulation
    end
endmodule

/*
`timescale 10ns / 100ps

module Ethernet_tx_rx_tb;
    // Signals
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data_in;
    reg tx_data_valid;
    wire tx_ready;
    wire tx_done;
    wire [7:0] tx_data_out;
    wire [7:0] rx_data_out;
    wire rx_data_valid;
    reg rx_data_ready;

    reg [47:0] src_mac;
    reg [47:0] dest_mac;

    // Instantiate the top-level Ethernet module
    Ethernet_tx_rx uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data_in(tx_data_in),
        .tx_data_valid(tx_data_valid),
        .tx_ready(tx_ready),
        .tx_done(tx_done),
        .tx_data_out(tx_data_out),
        .rx_data_out(rx_data_out),
        .rx_data_valid(rx_data_valid),
        .rx_data_ready(rx_data_ready),
        .src_mac(src_mac),
        .dest_mac(dest_mac)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 ns clock period
    end

    integer i;

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        tx_start = 0;
        tx_data_in = 0;
        tx_data_valid = 0;
        rx_data_ready = 0;

        src_mac = 48'h112233445566;   // Example source MAC address
        dest_mac = 48'hAABBCCDDEEFF;  // Example destination MAC address

        // Reset the system
        #20 rst = 0;
        #10;

        // Begin transmission
        tx_start = 1;
        #10;
        tx_start = 0;

        // Transmit frame payload (example data)
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            tx_data_in = i + 8'hBA;  // Example payload data
            tx_data_valid = 1;
            #10;
        end
        tx_data_valid = 0;

        // Wait for transmission to complete
        @(posedge tx_done);
        $display("Transmission complete.");

        // Enable data reception
        rx_data_ready = 1;

        // Monitor received data
        i = 0;
        while (i < 16) begin
            @(posedge clk);
            if (rx_data_valid) begin
                $display("Received data byte %0d: %h", i, rx_data_out);
                i = i + 1;
            end
        end

        // End simulation after verification
        #100;
        $display("Test complete.");
        $stop;
    end
endmodule
*/