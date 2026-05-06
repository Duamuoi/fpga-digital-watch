`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = WIDTH'(0)
);

  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk) if (enable) count <= next_count;

  always_comb begin
    if (up) begin
      if (count == WIDTH'(MAX)) next_count = WIDTH'(0);
      else next_count = count + 1'b1;
    end else begin
      if (count == WIDTH'(0)) next_count = WIDTH'(MAX);
      else next_count = count - 1'b1;
    end
  end

endmodule
