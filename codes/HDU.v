module HDU (
    RS1addr_i,
    RS2addr_i,
    PCWrite_o,
    Stall_o,
    NoOP_o,
    RDaddr_i,
    MemRead_i
);

input [4:0] RS1addr_i, RS2addr_i, RDaddr_i;
input MemRead_i;
output reg PCWrite_o, Stall_o;
output reg NoOP_o;

always @(*) begin
    if (MemRead_i
    && ((RS1addr_i == RDaddr_i) || (RS2addr_i == RDaddr_i))) begin
        NoOP_o <= 1'b1;
        Stall_o <= 1'b1;
        PCWrite_o <= 1'b0;
    end
    else begin
        NoOP_o <= 1'b0;
        Stall_o <= 1'b0;
        PCWrite_o <= 1'b1;
    end

end
endmodule