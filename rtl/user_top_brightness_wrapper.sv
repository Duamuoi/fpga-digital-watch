`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
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
  logic [PWMWidth:0] pwm_count_ext;
  logic [PWMWidth:0] duty_cycles;

  logic pwm_blank;

  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  mod_n_counter #(
      .N(PWMPeriod),
      .WIDTH(PWMWidth)
  ) pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  assign pwm_count_ext = {1'b0, pwm_count};

  always_comb begin
    unique case (sw[9:8])
      2'b00:   duty_cycles = PWMPeriod / 8;  // Dim:    12.5%
      2'b01:   duty_cycles = PWMPeriod / 4;  // Low:    25%
      2'b11:   duty_cycles = PWMPeriod / 2;  // Medium: 50%
      2'b10:   duty_cycles = PWMPeriod;  // Full:   100%
      default: duty_cycles = PWMPeriod;
    endcase
  end

  assign pwm_blank = (pwm_count_ext < PWM_PERIOD) && (pwm_count_ext >= duty_cycles);

  user_top #(
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
