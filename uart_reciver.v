`timescale 1ns / 1ps

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217

module uart_receiver(
  input clk, rst, rx,
  output [7:0] d_out,
  output rx_ready
);

  reg [7:0] data_reg; // Data bits received
  reg [1:0] state; // Receiver state machine state
  reg [7:0] clk_counter; // Counter for bit timing
  reg [3:0] bit_index; // Index for received data bits

  // State machine states
  localparam IDLE      = 2'b00;
  localparam START_BIT = 2'b01;
  localparam DATA_BITS = 2'b10;
  localparam STOP_BIT  = 2'b11;

  // Clock cycles per bit (adjust according to UART configuration)
  parameter clk_per_bit = 217;

  assign rx_ready = (state == STOP_BIT)? 1'b1 : 1'b0;
  assign d_out = (state == STOP_BIT) ? data_reg : 8'hZZ; // Set to high impedance when not in STOP_BIT

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE; // Synchronous reset
    end else begin
      case (state)
        IDLE: begin
          bit_index <= 0;
          if (!rx) begin
            if (clk_counter < (clk_per_bit - 1) / 2) begin
              clk_counter <= clk_counter + 1;
              state <= IDLE; // Wait for start bit
            end else begin
              clk_counter <= 0;
              //rx_ready <= 1'b0;
              state <= START_BIT; // Start bit detected
            end
          end
        end
        START_BIT: begin
          if (clk_counter < clk_per_bit - 1) begin
            clk_counter <= clk_counter + 1;
            state <= START_BIT; // Continue processing start bit
          end else begin
            clk_counter <= 0;
            state <= DATA_BITS; // Proceed to data bits
          end
        end
        DATA_BITS: begin
          data_reg[bit_index] <= rx; // Store received data bit
          if (clk_counter < clk_per_bit - 1) begin
            clk_counter <= clk_counter + 1;
            state <= DATA_BITS; // Continue processing data bits
          end else if (bit_index < 8) begin
            clk_counter <= 0;
            bit_index <= bit_index + 1;
            state <= DATA_BITS; // Proceed to the next data bit
          end else begin
            clk_counter <= 0;
            bit_index <= 0;
            state <= STOP_BIT; // Proceed to stop bit
          end
        end
        STOP_BIT: begin
          if (rx) begin
            if (clk_counter < clk_per_bit - 1) begin
              clk_counter <= clk_counter + 1;
              state <= STOP_BIT; // Continue processing stop bit
            end else begin
              clk_counter <= 0;
              //d_out <= data_reg;
              //rx_ready <= 1'b1;
              state <= IDLE; // Return to IDLE state
            end
          end
        end
      endcase
    end
  end
endmodule
