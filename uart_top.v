module uart_top (
    input clk, rst, write_en, ready_clr,
    input [7:0] data_in,
    output ready, busy,
    output [7:0] data_out
);

wire rx_clk_en;
wire tx_clk_en;
wire tx_temp;

baudRate_generator baud(clk, rst, tx_clk_en, rx_clk_en);
transmitter tx(clk, rst, write_en, tx_clk_en, data_in, tx_temp, busy);
receiver rx(clk, rst, tx_temp, ready_clr, rx_clk_en, ready, data_out);

endmodule