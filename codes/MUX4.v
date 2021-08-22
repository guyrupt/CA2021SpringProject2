module MUX4 (
    out,
    i0,
    i1,
    i2,
    i3,
    sel
);
    
output [31:0] out;
input [31:0] i0, i1, i2, i3;
input [1:0] sel;

assign out = (sel == 2'b00)? i0:
             (sel == 2'b01)? i1:
             (sel == 2'b10)? i2:
             (sel == 2'b11)? i3:
             4'bx;

endmodule