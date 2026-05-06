`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,
    parameter int N_MINUTES = 60,
    parameter int N_SECONDS = 60,

    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,

    output logic [  W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);

  logic second_rollover;
  logic minute_rollover;

  localparam logic [W_HOURS-1:0] MaxHours = W_HOURS'(N_HOURS - 1);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  assign second_rollover = enable && (seconds == MaxSeconds);
  assign minute_rollover = second_rollover && (minutes == MaxMinutes);

  up_down_counter #(
      .MAX  (MaxHours),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up(1'b1),
      .count(hours)
  );

  up_down_counter #(
      .MAX  (MaxMinutes),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (MaxSeconds),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

endmodule
