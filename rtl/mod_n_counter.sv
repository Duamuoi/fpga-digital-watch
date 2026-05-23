`timescale 1ns / 1ps
module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = '0
);

  logic [WIDTH-1:0] next_count;

  // Next-state logic
  always_comb begin
    if (count == WIDTH'(N - 1)) next_count = '0;
    else next_count = count + 1'b1;
  end

  // Flip-flop with synchronous reset
  always_ff @(posedge clk) begin
    if (rst) count <= '0;
    else if (enable) count <= next_count;
  end

endmodule
