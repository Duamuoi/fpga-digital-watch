`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input  logic       clk,
    input  logic [3:0] button,
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  localparam int HoldCycle = CYCLES_PER_SECOND / 2;
  localparam int REPEATCYCLES = CYCLES_PER_SECOND / 10;

  localparam int FLASHPERIOD = CYCLES_PER_SECOND / 2;
  localparam int FLASHDUTY = (FLASHPERIOD * 4) / 5;

  logic [2:0] mode_enable;
  logic editing;
  logic running = 1'b0;

  logic button0_press;
  logic inc_pulse;
  logic dec_pulse;

  logic one_hz_tick;
  logic flash;

  logic sec_borrow;
  logic min_borrow;
  logic hour_borrow;

  logic all_zero;

  assign editing = (mode_enable != 3'b000);

  assign all_zero = (hours_disp == 7'd0) && (minutes_disp == 7'd0) && (seconds_disp == 7'd0);

  assign led = sw;

`ifdef FORMAL
  assign probe_running     = running;
  assign probe_mode_enable = mode_enable;
`endif

  // Avoid unused button[2] lint warning.
  /* verilator lint_off UNUSED */
  logic unused_button2;
  assign unused_button2 = button[2];
  logic unused_hour_borrow;
  assign unused_hour_borrow = hour_borrow;
  /* verilator lint_on UNUSED */

  rising_edge_detector u_button0_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(button0_press)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (HoldCycle),
      .REPEAT_CYCLES(REPEATCYCLES)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (HoldCycle),
      .REPEAT_CYCLES(REPEATCYCLES)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_edit_mode (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_one_hz (
      .clk (clk),
      .run (running),
      .tick(one_hz_tick)
  );

  pwm_generator #(
      .PERIOD_CYCLES(FLASHPERIOD),
      .DUTY_CYCLES  (FLASHDUTY)
  ) u_flash (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(flash)
  );

  assign blank_seconds = mode_enable[0] && flash;
  assign blank_minutes = mode_enable[1] && flash;
  assign blank_hours   = mode_enable[2] && flash;

  always_ff @(posedge clk) begin
    if (editing || all_zero) begin
      running <= 1'b0;
    end else if (button0_press) begin
      running <= !running;
    end
  end

  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(running && one_hz_tick),
      .edit_mode(mode_enable[0]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(seconds_disp),
      .borrow_out(sec_borrow)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(running && sec_borrow),
      .edit_mode(mode_enable[1]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(minutes_disp),
      .borrow_out(min_borrow)
  );

  editable_countdown #(
      .MAX  (23),
      .WIDTH(7)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(running && min_borrow),
      .edit_mode(mode_enable[2]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(hours_disp),
      .borrow_out(hour_borrow)
  );

endmodule
