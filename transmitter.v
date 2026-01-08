module transmitter (
    input clk, rst, write_en, baud_en,
    input [7:0] data_in,
    output reg tx,
    output busy
);

    parameter idle_state = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state = 2'b10;
    parameter stop_state = 2'b11;
    
    reg [1:0] state = idle_state;

    reg [7:0] data;
    reg [3:0] index;


    always @(posedge clk or posedge rst) begin

        if (rst) begin
            tx <= 1'b1;
            data <= 8'b0;
            index <= 4'b0;
            state <= idle_state;
        end

        else  begin
            case (state)
                idle_state: if (write_en) begin 
                    state <= start_state;
                    data <= data_in;
                end
                start_state: if (baud_en) begin
                    state <= data_state;
                    tx <= 1'b0;
                    index <= 4'b0;
                end
                data_state: if (baud_en) begin
                    if (index == 4'd8) state <= stop_state;
                    else begin
                        index <= index + 4'h1;
                        tx <= data[index];
                    end
                end
                stop_state: if (baud_en) begin
                    state <= idle_state;
                    tx <= 1'b1;
                end
                default: begin
                    state <= idle_state;
                    tx <= 1'b1;
                end 
            endcase
        end

    end

    assign busy = (state != idle_state);
    
endmodule