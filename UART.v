`timescale 1ns / 1ps


module UART(
input clk, reset, start_tx,
input [7:0]data,
output tx_ready, tx
    );
    
reg [2:0] state, next_state;
reg [9:0] tx_shift_reg;
reg [3:0] tx_bit_count;
reg tx_busy;

wire tx_bit, baud_tick;

always@(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 3'b000;
        tx_shift_reg <= 10'b0;
        tx_bit_count <= 4'd0;
        tx_busy <= 1'b0;
        end
    else begin
        state <= next_state;
        tx_shift_reg <= {1'b0, data, 1'b1};
        tx_bit_count <= (tx_bit_count == 4'd9) ? 4'd0 : tx_bit_count + 1'b1;
        tx_busy <= (state == 3'b011);
        end
    end
    
always@(posedge clk) begin
if(tx_busy) begin
    if (baud_tick) begin
        tx_bit <= tx_shift_reg[0];
        tx_shift_reg <= {tx_shift_reg[8:0], 1'b0};
        end
    end
end


always@(*) begin
    case(state)
    0: next_state = (start_tx) ? 3'b001 : 3'b000;
    1: next_state = 3'b010;
    2: next_state = 3'b011;
    3: next_state = (tx_bit_count == 4'd9) ? 3'b000:3'b011;
    endcase
end
        
assign tx = tx_bit;
assign tx_ready = (state == 3'b000);

baud_rate_generator baud_gen(
.clk(clk),
.reset(reset),
.baud_tick(baud_tick)
);


endmodule
