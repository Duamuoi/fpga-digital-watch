`timescale 1ns / 1ps

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int WIDTH = (PERIOD_CYCLES <= 1) ? 1 : $clog2(PERIOD_CYCLES);

  logic [WIDTH-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(WIDTH)
  ) pwm_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  always_comb begin
    if (DUTY_CYCLES >= PERIOD_CYCLES)
      pwm_out = 1'b1;
    else if (DUTY_CYCLES <= 0)
      pwm_out = 1'b0;
    else
      pwm_out = count < WIDTH'(DUTY_CYCLES);
  end

endmodule

