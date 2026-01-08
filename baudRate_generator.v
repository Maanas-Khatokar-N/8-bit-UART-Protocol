//==============================================================================
// Module: baudRate_generator
// Description: Parametrized baud rate generator for UART transmitter and 
//              receiver. TX operates at specified baud rate, RX uses 16x 
//              oversampling for robust data recovery.
//
// Parameters:
//   CLK_FREQ       - System clock frequency in Hz (default: 50 MHz)
//   BAUD_RATE      - Desired baud rate in bps (default: 9600)
//   OVERSAMPLE     - Oversampling factor for receiver (default: 16)
//
// Example calculation for default values:
//   TX samples per bit = CLK_FREQ/BAUD_RATE = 50e6/9600 = 5208
//   RX samples per bit = CLK_FREQ/(BAUD_RATE x 16) = 50e6/153600 = 325
//==============================================================================

module baudRate_generator #(
    parameter CLK_FREQ = 50000000,    // 50 MHz system clock
    parameter BAUD_RATE = 9600,       // 9600 bps
    parameter OVERSAMPLE = 16         // 16x oversampling for RX
)(
    input clk, rst,
    output tx_enable, rx_enable
);
    
    // Calculate counter max values
    localparam TX_MAX = CLK_FREQ / BAUD_RATE - 1;
    localparam RX_MAX = CLK_FREQ / (BAUD_RATE * OVERSAMPLE) - 1;
    
    // Determine counter widths based on max values
    localparam TX_WIDTH = $clog2(TX_MAX + 1);
    localparam RX_WIDTH = $clog2(RX_MAX + 1);
    
    reg [TX_WIDTH-1:0] tx_counter;  // Counter for transmitter baud rate
    reg [RX_WIDTH-1:0] rx_counter;  // Counter for receiver oversampled rate
    
    // Transmitter baud rate counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_counter <= 0;
        end
        else if (tx_counter == TX_MAX) begin
            tx_counter <= 0;
        end
        else begin
            tx_counter <= tx_counter + 1'b1;
        end
    end
    
    // Receiver baud rate counter (with oversampling)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_counter <= 0;
        end
        else if (rx_counter == RX_MAX) begin
            rx_counter <= 0;
        end
        else begin
            rx_counter <= rx_counter + 1'b1;
        end
    end
    
    // Generate enable pulses when counters reach zero
    assign tx_enable = (tx_counter == 0);
    assign rx_enable = (rx_counter == 0);
    
endmodule
