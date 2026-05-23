`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic clk,
    input  logic rst,      // Takes priority over enable
    input  logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  localparam int Cyclepercentisecond = CYCLES_PER_SECOND / 100;

  logic tick_cs;
  logic counter_enable;

  restartable_rate_generator #(
      .CYCLE_COUNT(Cyclepercentisecond)
  ) u_rate (
      .clk(clk),
      .run(enable && !rst),
      .tick(tick_cs)
  );

  assign counter_enable = enable && tick_cs;

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(counter_enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
