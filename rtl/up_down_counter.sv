`timescale 1ns/1ps

module up_down_counter #(
    parameter int MAX = 2,
    parameter int WIDTH = 2
) (
    input  logic clk,
    input  logic enable,
    input  logic up,
    output logic [WIDTH-1:0] count
);

logic [WIDTH-1:0] next_count;

initial count = '0;

always_ff @(posedge clk) begin
    count <= next_count;
end

always_comb begin
    next_count = count;

    if (enable) begin
        if (up) begin
            if (count == MAX)
                next_count = '0;
            else
                next_count = count + 1'b1;
        end else begin
            if (count == 0)
                next_count = MAX[WIDTH-1:0];
            else
                next_count = count - 1'b1;
        end
    end
end

endmodule
