//==============================================================================
// Module: uart_top
// Description: Top-level UART module integrating baud rate generator, 
//              transmitter, and receiver. Implements full-duplex serial
//              communication with 8N1 protocol. Provides simple parallel
//              interface for data input/output with control signals.
//==============================================================================

module uart_top (
    input clk, rst, write_en, ready_clr,
    input [7:0] data_in,
    output ready, busy,
    output [7:0] data_out
);
    
    // Internal signals
    wire rx_clk_en;     // Receiver baud rate enable (16x oversampled)
    wire tx_clk_en;     // Transmitter baud rate enable
    wire tx_temp;       // Serial data line connecting TX to RX
    
    // Baud rate generator instance
    baudRate_generator baud(clk, rst, tx_clk_en, rx_clk_en);
    
    // Transmitter instance
    transmitter tx(clk, rst, write_en, tx_clk_en, data_in, tx_temp, busy);
    
    // Receiver instance
    receiver rx(clk, rst, tx_temp, ready_clr, rx_clk_en, ready, data_out);
    
endmodule
