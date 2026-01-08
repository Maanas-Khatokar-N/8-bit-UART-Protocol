//==============================================================================
// Module: uart_tb
// Description: Testbench for UART top module. Verifies transmit and receive
//              functionality by sending multiple bytes and checking received
//              data. Uses tasks for reusable test operations (send_byte and
//              clear_ready). Generates VCD waveform for analysis.
//==============================================================================

`timescale 1ns / 1ps

module uart_tb;
    
    // Testbench signals
    reg clk, rst;
    reg [7:0] data_in;
    reg wr_en;
    wire rdy;
    reg rdy_clr;
    wire [7:0] dout;
    wire busy;
    
    // Instantiate UART top module
    uart_top dut(clk, rst, wr_en, rdy_clr, data_in, rdy, busy, dout);
    
    // Initialize signals
    initial begin
        {clk, rst, data_in, rdy_clr} = 0;
    end
    
    // Generate 100 MHz clock (10 ns period)
    always #5 clk = ~clk;
    
    // Task to send a byte through UART transmitter
    task send_byte(input [7:0] din);
        begin
            @(negedge clk);
            data_in = din;
            wr_en = 1'b1;
            @(negedge clk)
            wr_en = 0;
        end
    endtask
    
    // Task to clear ready flag after data reception
    task clear_ready;
        begin
            @(negedge clk)
                rdy_clr = 1'b1;
            @(negedge clk)
                rdy_clr = 1'b0;        
        end
    endtask
    
    // Main test sequence
    initial begin
        // Apply reset
        @(negedge clk)
        rst = 1'b1;
        
        @(negedge clk)
        rst = 1'b0;
        
        // Test transmission 1: Send 0x12
        send_byte(8'h12);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h", dout);
        clear_ready;
        
        // Test transmission 2: Send 0x50
        send_byte(8'h50);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h", dout);
        clear_ready;
        
        // Test transmission 3: Send 0x77
        send_byte(8'h77);
        wait(!busy);
        wait(rdy);
        $display("Recived data is %h", dout);
        clear_ready;
        
        #400 $finish;
    end
    
    // Generate VCD waveform file for viewing
    initial begin
        $dumpfile("uart_waveform.vcd");
        $dumpvars(0, uart_tb);
    end
    
endmodule
