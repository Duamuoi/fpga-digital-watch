`timescale 1ns/1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic hold_pulse;
  logic pulse_train;
  logic repeat_run;

  assign repeat_run = held && !hold_pulse;

  assign pulse = rise | hold_pulse | (held & pulse_train);

  rising_edge_detector u_rise_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(hold_pulse)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_repeat_rate (
      .clk (clk),
      .run (repeat_run),
      .tick(pulse_train)
  );

endmodule
