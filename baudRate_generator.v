/*
    Clock freq = 50 MHz
    Baude rate = 9600 bps

    No. of sample per bit = clk_freq/baude_rate
    For transmitter: No. of sample per bit = 50e6/9600 = 5208
    For transmitter: No. of sample per bit = 50e6/(9600x16) = 325   ->  Oversampling is done so that there is no mismatch between tx and rx 
*/


module baudRate_generator (
    input clk, rst,
    output tx_enable, rx_enable
);

    reg [12:0] tx_counter;
    reg [9:0] rx_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_counter <= 0;
        end
        else if (tx_counter == 5208) begin
            tx_counter <= 0;
        end
        else begin
            tx_counter <= tx_counter + 1'b1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_counter <= 0;
        end
        else if (rx_counter == 325) begin
            rx_counter <= 0;
        end
        else begin
            rx_counter <= rx_counter + 1'b1;
        end
    end

    assign tx_enable = (tx_counter == 0);
    assign rx_enable = (rx_counter == 0);

endmodule