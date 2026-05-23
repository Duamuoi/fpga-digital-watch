`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input  logic clk,
    input  logic rst,
    input  logic enable,
    input  logic up,
    output logic [WIDTH-1:0] count = WIDTH'(0)
);

  logic [WIDTH-1:0] next_count;

  always_ff @(posedge clk) begin
    if (rst)
      count <= WIDTH'(0);
    else if (enable)
      count <= next_count;
  end

  always_comb begin
    if (up) begin
      if (count == WIDTH'(MAX))
        next_count = WIDTH'(0);
      else
        next_count = count + WIDTH'(1);
    end else begin
      if (count == WIDTH'(0))
        next_count = WIDTH'(MAX);
      else
        next_count = count - WIDTH'(1);
    end
  end

endmodule
