//==============================================================================
// Module: receiver
// Description: UART receiver module implementing 8N1 protocol (8 data bits, 
//              no parity, 1 stop bit). Samples incoming serial data at 16x 
//              the baud rate for robust bit detection. Outputs received byte
//              and ready signal when frame reception is complete.
//==============================================================================

module receiver (
    input clk, rst, rx, ready_clr, baud_en,
    output reg ready,
    output reg [7:0] data_out 
);
    
    // State encoding for UART receive FSM
    parameter start_state = 2'b01;
    parameter data_out_state = 2'b10;
    parameter stop_state = 2'b11;

    reg [1:0] state = start_state;
    reg [3:0] sample = 0;      // Sample counter for 16x oversampling
    reg [3:0] index = 0;       // Bit index counter (0-7)
    reg [7:0] temp_data;       // Temporary storage for incoming data

    // Asynchronous reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready <= 1'b0;
            data_out <= 8'b0;
        end
    end

    // Main FSM and data sampling logic
    always @(posedge clk) begin
        if (ready_clr) ready <= 0;
        if (baud_en) begin
            case (state)
                // Detect and verify start bit
                start_state: begin
                    if (rx == 0 || sample != 0) sample <= sample + 1'b1;
                    if (sample == 15) begin
                        state <= data_out_state;
                        sample <= 0;
                        index <= 0;
                        temp_data <= 8'b0; 
                    end
                end
                
                // Sample 8 data bits at mid-bit timing
                data_out_state: begin
                    sample <= sample + 1'b1;
                    if (sample == 4'd8) begin
                        temp_data[index] <= rx;
                        index <= index + 1'b1;
                    end
                    if (index == 8 && sample == 15) state <= stop_state;
                end
                
                // Verify stop bit and output received data
                stop_state: begin
                    if (sample == 15) begin
                        state <= start_state;
                        data_out <= temp_data;
                        ready <= 1'b1;
                        sample <= 0;
                    end
                    else sample <= sample + 1'b1;
                end
                
                default: state <= start_state;
            endcase
        end 
    end

endmodule
