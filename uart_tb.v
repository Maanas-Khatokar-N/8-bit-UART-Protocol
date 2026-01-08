`timescale 1ns / 1ps

module uart_tb;

reg clk,rst;
reg [7:0] data_in;
reg wr_en;

wire rdy;
reg rdy_clr;
wire [7:0] dout;

wire busy;

uart_top dut(clk, rst, wr_en, rdy_clr, data_in, rdy, busy, dout);

initial
begin
    {clk,rst,data_in,rdy_clr} = 0;
end

always #5 clk = ~clk;
 
task send_byte(input [7:0] din);
    begin
        @(negedge clk);
        data_in = din;
        wr_en = 1'b1;
        @(negedge clk)
        wr_en = 0;
        
    end
endtask

    
task clear_ready;
    begin
        @(negedge clk)
            rdy_clr = 1'b1;
        @(negedge clk)
            rdy_clr = 1'b0;        
    end
endtask
       
       
initial
    begin
        @(negedge clk)
        rst = 1'b1;
        
        @(negedge clk)
        rst = 1'b0;
        
        send_byte(8'h12);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h",dout);
        clear_ready;
        
        
        send_byte(8'h50);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h",dout);
        clear_ready;

        send_byte(8'h77);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h",dout);
        clear_ready;
        
        #400 $finish;
    end

    initial begin
    $dumpfile("uart_waveform.vcd");
    $dumpvars(0, uart_tb);
    end

endmodule        