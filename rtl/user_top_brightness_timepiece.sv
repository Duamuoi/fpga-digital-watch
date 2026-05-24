`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
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

  localparam int PWMPeriod = CYCLES_PER_SECOND / 1000;
  localparam int PWMWidth = (PWMPeriod <= 1) ? 1 : $clog2(PWMPeriod);

  logic [PWMWidth-1:0] pwm_count;
  logic [  PWMWidth:0] pwm_count_ext;
  logic [  PWMWidth:0] duty_cycles;
  logic [  PWMWidth:0] pwm_period_ext;
  logic [         1:0] brightness_sel;

  logic                pwm_blank;

  logic                app_blank_hours;
  logic                app_blank_minutes;
  logic                app_blank_seconds;

  assign brightness_sel = sw[9:8];

  assign pwm_period_ext = (PWMWidth + 1)'(PWMPeriod);
  assign pwm_count_ext  = {1'b0, pwm_count};

  mod_n_counter #(
      .N(PWMPeriod),
      .WIDTH(PWMWidth)
  ) pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  always_comb begin
    unique case (brightness_sel)
      2'b00:   duty_cycles = (PWMWidth + 1)'(PWMPeriod / 8);  // Dim
      2'b01:   duty_cycles = (PWMWidth + 1)'(PWMPeriod / 4);  // Low
      2'b11:   duty_cycles = (PWMWidth + 1)'(PWMPeriod / 2);  // Medium
      2'b10:   duty_cycles = (PWMWidth + 1)'(PWMPeriod);  // Full
      default: duty_cycles = (PWMWidth + 1)'(PWMPeriod);
    endcase
  end

  assign pwm_blank = (pwm_count_ext < pwm_period_ext) && (pwm_count_ext >= duty_cycles);

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) app (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  assign blank_hours   = app_blank_hours | pwm_blank;
  assign blank_minutes = app_blank_minutes | pwm_blank;
  assign blank_seconds = app_blank_seconds | pwm_blank;

endmodule
