`timescale 1ns / 1ps

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217

module uart_transmitter(
  input clk, rst, tx_start,
  input [7:0] data,
  output reg tx, tx_ready
);

  reg [7:0] data_reg; // Data to be transmitted
  reg start_reg; // Start bit flag
  reg [1:0] state; // State machine state
  reg [7:0] clk_counter; // Counter for bit timing
  reg [3:0] bit_index; // Index for data bits

  // State machine states
  localparam IDLE      = 2'b00;
  localparam START_BIT = 2'b01;
  localparam DATA_BITS = 2'b10;
  localparam STOP_BIT  = 2'b11;

  // Clock cycles per bit (You should adjust this according to your UART settings)
  parameter clk_per_bit = 217;

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE; // Synchronous reset
    end else begin
      case(state)
        IDLE: begin
          tx <= 1'b1; // Idle state, TX high
          clk_counter <= 0;
          bit_index <= 0;
          tx_ready <= 1'b1;
          if (tx_start) begin
            data_reg <= data; // Load data
            tx_ready <= 1'b0;
            state <= START_BIT;
          end
        end
        START_BIT: begin
          tx <= 1'b0; // Start bit, TX low
          if (clk_counter < clk_per_bit - 1) begin
            clk_counter <= clk_counter + 1;
            state <= START_BIT;
          end else begin
            clk_counter <= 0;
            state <= DATA_BITS;
          end
        end
        DATA_BITS: begin
          tx <= data_reg[bit_index]; // Transmit data bit
          if (clk_counter < clk_per_bit - 1) begin
            clk_counter <= clk_counter + 1;
            state <= DATA_BITS;
          end else if (bit_index < 7) begin
            clk_counter <= 0;
            bit_index <= bit_index + 1;
            state <= DATA_BITS;
          end else begin
            clk_counter <= 0;
            bit_index <= 0;
            state <= STOP_BIT;
          end
        end
        STOP_BIT: begin
          tx <= 1'b1; // Stop bit, TX low
          if (clk_counter < clk_per_bit - 1) begin
            clk_counter <= clk_counter + 1;
            state <= STOP_BIT;
          end else begin
            clk_counter <= 0;
            state <= IDLE; // Return to idle state
          end
        end
      endcase
    end
  end
endmodule
