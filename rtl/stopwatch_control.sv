`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst    = 1'b0,
    output logic counter_enable = 1'b0,
    output logic lap_hold       = 1'b0
);

  logic both;
  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  assign both = rise_start_stop && rise_lap;

  // Start/stop toggles running state.
  // Simultaneous button presses are ignored.
  assign next_counter_enable =
      both ? counter_enable :
      rise_start_stop ? ~counter_enable :
      counter_enable;

  // Lap hold toggles only on lap press while not resetting.
  // If stopped/live and lap is pressed, that means reset, not freeze.
  assign next_lap_hold =
      both ? lap_hold :
      rise_lap && !(counter_enable == 1'b0 && lap_hold == 1'b0) ? ~lap_hold :
      lap_hold;

  // Reset is a one-cycle pulse.
  always_comb begin
    next_counter_rst = 1'b0;

    if (!both) begin
      if (rise_lap && !counter_enable && !lap_hold)
        next_counter_rst = 1'b1;
    end
  end

  always_ff @(posedge clk) begin
    counter_rst    <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold       <= next_lap_hold;
  end

endmodule
