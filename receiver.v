module receiver (
    input clk, rst, rx, ready_clr, baud_en,
    output reg ready,
    output reg [7:0] data_out 
);
    
    parameter start_state = 2'b01;
    parameter data_out_state = 2'b10;
    parameter stop_state = 2'b11;

    reg [1:0] state = start_state;
    reg [3:0] sample = 0;
    reg [3:0] index = 0;
    reg [7:0] temp_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ready <= 1'b0;
            data_out <= 8'b0;
        end
    end

    always @(posedge clk) begin
        if (ready_clr) ready <= 0;
        if (baud_en) begin
            case (state)
                start_state: begin
                    if (rx == 0 || sample != 0) sample <= sample + 1'b1;
                    if (sample == 15) begin
                        state <= data_out_state;
                        sample <= 0;
                        index <= 0;
                        temp_data <= 8'b0; 
                    end
                end
                data_out_state: begin
                    sample <= sample + 1'b1;
                    if (sample == 4'd8) begin
                        temp_data[index] <= rx;
                        index <= index + 1'b1;
                    end
                    if (index == 8 && sample == 15) state <= stop_state;
                end
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