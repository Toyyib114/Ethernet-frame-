module Ethernet_tx_rx ( 
    input wire clk,                // Clock signal for synchronization
    input wire rst,                // Reset signal for initializing the module
    input wire tx_start,           // Start signal for initiating transmission
    input wire [7:0] tx_data_in,  // 8-bit data input for transmission
    input wire tx_data_valid,     // Signal indicating if the tx_data_in is valid
    output wire tx_ready,          // Signal indicating that the transmitter is ready to send data
    output wire tx_done,           // Signal indicating that the transmission has completed
    output wire [7:0] tx_data_out,// 8-bit output for transmitted data
    input wire [7:0] rx_data_in,  // 8-bit incoming data for reception (simulated for testing)
    output wire [7:0] rx_data_out,// 8-bit output for received data
    output wire rx_data_valid,    // Signal indicating if the received data is valid
    input wire rx_data_ready,     // Signal indicating the receiver is ready to receive data
    input wire [47:0] src_mac,    // Source MAC address for both transmission and reception
    input wire [47:0] dest_mac    // Destination MAC address for both transmission and reception
);

    // Instantiate the Ethernet transmitter module (tx_inst)
    Ethernet_tx tx_inst (
        .clk(clk),                  // Connect clock
        .rst(rst),                  // Connect reset
        .tx_start(tx_start),        // Connect transmission start signal
        .tx_data_in(tx_data_in),   // Connect input data for transmission
        .tx_data_valid(tx_data_valid), // Connect valid signal for transmission data
        .tx_ready(tx_ready),        // Output signal indicating when transmitter is ready
        .tx_done(tx_done),          // Output signal indicating when transmission is complete
        .tx_data_out(tx_data_out), // Transmitted data output
        .src_mac(src_mac),          // Source MAC address for transmission
        .dest_mac(dest_mac)         // Destination MAC address for transmission
    );

    // Instantiate the Ethernet receiver module (rx_inst)
    Ethernet_rx rx_inst (
        .clk(clk),                  // Connect clock
        .rst(rst),                  // Connect reset
        .rx_data_valid(tx_done),    // rx_data_valid is set high when transmission is done (assuming reception after transmission)
        .rx_data_in(tx_data_out),  // Simulate reception by feeding back tx_data_out (the transmitted data)
        .rx_data_ready(rx_data_ready), // Ready signal from receiver (valid when ready to receive data)
        .rx_data_out(rx_data_out), // Output received data
        .rx_done(rx_data_valid),   // Signal indicating when data reception is complete and valid
        .src_mac(src_mac),          // Source MAC address for reception
        .dest_mac(dest_mac)         // Destination MAC address for reception
    );

endmodule

/*module Ethernet_tx_rx (
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data_in,
    input wire tx_data_valid,
    output wire tx_ready,
    output wire tx_done,
    output wire [7:0] tx_data_out,
    input wire [7:0] rx_data_in,
    output wire [7:0] rx_data_out,
    output wire rx_data_valid,
    input wire rx_data_ready,
    input wire [47:0] src_mac,
    input wire [47:0] dest_mac
);
    // Instantiate transmitter and receiver modules
    Ethernet_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data_in(tx_data_in),
        .tx_data_valid(tx_data_valid),
        .tx_ready(tx_ready),
        .tx_done(tx_done),
        .tx_data_out(tx_data_out),
        .src_mac(src_mac),
        .dest_mac(dest_mac)
    );

    Ethernet_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx_data_valid(tx_done),  // Assume the received data is valid after transmission completes
        .rx_data_in(tx_data_out), // Send tx_data_out as rx_data_in for testing
        .rx_data_ready(rx_data_ready),
        .rx_data_out(rx_data_out),
        .rx_done(rx_data_valid),
        .src_mac(src_mac),
        .dest_mac(dest_mac)
    );
endmodule
*/