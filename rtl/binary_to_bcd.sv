// binary to Binary-coded Decimal

module binary_to_bcd
    (
    input logic [6:0] bin, //binary input 0-99
    output logic [3:0] tens, // decimal tens digit (BCD)
    output logic [3:0] ones // decimal ones digit (BCD)
);
always_comb begin
    tens = bin / 10;
    ones = bin % 10;
end

endmodule
