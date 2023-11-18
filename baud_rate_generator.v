`timescale 1ns / 1ps

module baud_rate_generator(
input wire clk, reset,
output wire baud_tick
    );
    
parameter BAUD_RATE = 9600;
parameter SYS_CLK_FREQ = 50000000;

reg [15:0]bit_period_counter;

always@(posedge clk or posedge reset)
begin
if (reset)
    bit_period_counter <= 16'h0;
else
    bit_period_counter <= (bit_period_counter == SYS_CLK_FREQ / BAUD_RATE -1) ? 16'h0 : bit_period_counter +1'b1;
end

assign baud_tick = (bit_period_counter == SYS_CLK_FREQ / BAUD_RATE -1);

endmodule
