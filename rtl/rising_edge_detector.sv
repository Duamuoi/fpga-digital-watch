`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic sig_prev = 1'b0;

  // Store previous sampled value of sig_in
  always_ff @(posedge clk) begin
    sig_prev <= sig_in;
  end

  // Mealy output logic:
  // rise goes high immediately when sig_in is high
  // and the previously sampled value was low.
  always_comb begin
    rise = sig_in & ~sig_prev;
  end

endmodule

