module Control (
    Op_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemtoReg_o,
    MemWrite_o,
    MemRead_o,
    Branch_o,
    NoOP_i
);

input NoOP_i;
input [6:0] Op_i;
output [1:0] ALUOp_o;
output ALUSrc_o;
output RegWrite_o;
output MemtoReg_o, MemWrite_o, MemRead_o, Branch_o;

wire flush;
assign flush = (Op_i == 7'b0) ? 1:0;
assign ALUSrc_o = ((Op_i == 7'b0010011) //addi
                ||(Op_i == 7'b0000011)  //srai
                ||(Op_i == 7'b0000011)  //lw
                ||(Op_i == 7'b0100011)) ? 1: //sw
                (NoOP_i) ? 0:
                (flush) ? 0:
                0; 
assign RegWrite_o = ((Op_i == 7'b0100011)
                ||(Op_i == 7'b1100011)) ? 0: // sd & beq
                (NoOP_i) ? 0: 
                (flush) ? 0:
                1; 
assign ALUOp_o = (Op_i == 7'b0010011) ? 2'b00: // addi & srai
                 (Op_i == 7'b0000011) ? 2'b00: //lw
                 (Op_i == 7'b0100011) ? 2'b00: //sw
                 (Op_i == 7'b1100011) ? 2'b01: //beq
                 (NoOP_i) ? 0:
                 (flush) ? 0:
                2'b10; 
assign MemtoReg_o = (Op_i == 7'b0000011) ? 1: // ld
                (NoOP_i) ? 0:
                (flush) ? 0:
                0;  
assign MemWrite_o = (Op_i == 7'b0100011) ? 1: // sd
                (NoOP_i) ? 0:
                (flush) ? 0:
                0; 
assign MemRead_o = (Op_i == 7'b0000011) ? 1: // ld
                (NoOP_i) ? 0:
                (flush) ? 0:
                0; 
assign Branch_o = (Op_i == 7'b1100011) ? 1: //beq
                (NoOP_i) ? 0:
                (flush) ? 0:
                0; 

endmodule