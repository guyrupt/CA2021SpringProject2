module Equal (
    i1,
    i2,
    out
);

input [31:0] i1, i2;
output out;

assign out = (i1 == i2) ? 1:0;

endmodule