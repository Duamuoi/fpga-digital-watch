// ------------------------------------------------------------------
//Core functionality
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_watch_v4 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,

    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */

    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);


  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Minutes

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;

  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // -------------------------
  // Seconds Tick Realignment
  // -------------------------

  logic edit_button_press;
  logic realign_seconds_tick;
  logic seconds_rate_run;

  rising_edge_detector u_edit_button_edge (
      .clk(clk),
      .sig_in(button[3]),
      .rise(edit_button_press)
  );

  assign realign_seconds_tick = mode_enable[0] && edit_button_press;
  assign seconds_rate_run     = ~realign_seconds_tick;

  // Derive 1Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (seconds_rate_run),
      .tick(seconds_tick)
  );

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  logic pwm_out;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 8 / 10)
  ) u_flash_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit   = mode_enable[2];

  // ----------
  // Edit Logic
  // ----------

  logic edit_active;
  logic inc_event;
  logic dec_event;

  localparam int Edithold = (CYCLES_PER_SECOND / 2) + 1;
  localparam int Editrepeat = CYCLES_PER_SECOND / 10;

  assign edit_active = |mode_enable;

  button_auto_repeat #(
      .HOLD_CYCLES  (Edithold),
      .REPEAT_CYCLES(Editrepeat)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1] & edit_active),
      .pulse(inc_event)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (Edithold),
      .REPEAT_CYCLES(Editrepeat)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0] & edit_active),
      .pulse(dec_event)
  );

  assign seconds_inc   = mode_enable[0] && inc_event;
  assign minutes_inc   = mode_enable[1] && inc_event;
  assign hours_inc     = mode_enable[2] && inc_event;

  assign seconds_dec   = mode_enable[0] && dec_event;
  assign minutes_dec   = mode_enable[1] && dec_event;
  assign hours_dec     = mode_enable[2] && dec_event;

  assign minutes_tick  = seconds_tick && (seconds == 6'd59);
  assign hours_tick    = seconds_tick && (seconds == 6'd59) && (minutes == 6'd59);

  // Zero-extend counter values to display outputs
  assign hours_disp    = {2'b0, hours};
  assign minutes_disp  = {1'b0, minutes};
  assign seconds_disp  = {1'b0, seconds};


  assign led           = 10'b0;
  assign blank_seconds = mode_enable[0] && ~pwm_out;
  assign blank_minutes = mode_enable[1] && ~pwm_out;
  assign blank_hours   = mode_enable[2] && ~pwm_out;


endmodule


