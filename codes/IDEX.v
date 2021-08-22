module IDEX (
    clk_i,
    start_i,
    stall,
    // in 
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    RS1data_i,
    RS2data_i,
    Imm_i,
    funct_i,
    RDaddr_i, 
    RS1addr_i,
    RS2addr_i, 
    // out
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RS1data_o,
    RS2data_o,
    Imm_o,
    funct_o,
    RDaddr_o,
    RS1addr_o,
    RS2addr_o
);

input clk_i, start_i, stall;
input RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i;
input [1:0] ALUOp_i;
input ALUSrc_i;
input [31:0] RS1data_i, RS2data_i;
input [31:0] Imm_i;
input [9:0] funct_i;
input [4:0] RDaddr_i, RS1addr_i, RS2addr_i;

output RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
output [1:0] ALUOp_o;
output ALUSrc_o;
output [31:0] RS1data_o, RS2data_o;
output [31:0] Imm_o;
output [9:0] funct_o;
output [4:0] RDaddr_o, RS1addr_o, RS2addr_o;

reg RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
reg [1:0] ALUOp_o;
reg ALUSrc_o;
reg signed [31:0] RS1data_o, RS2data_o;
reg signed [31:0] Imm_o;
reg [9:0] funct_o;
reg [4:0] RDaddr_o, RS1addr_o, RS2addr_o;

always @(posedge clk_i) begin
    if (start_i && !stall) begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        MemRead_o <= MemRead_i;
        MemWrite_o <= MemWrite_i;
        ALUOp_o <= ALUOp_i;
        ALUSrc_o <= ALUSrc_i;
        RS1data_o <= RS1data_i;
        RS2data_o <= RS2data_i;
        Imm_o <= Imm_i;
        funct_o <= funct_i;
        RDaddr_o <= RDaddr_i;
        RS1addr_o <= RS1addr_i;
        RS2addr_o <= RS2addr_i;
    end
    else begin
        RegWrite_o <= RegWrite_o;
        MemtoReg_o <= MemtoReg_o;
        MemRead_o <= MemRead_o;
        MemWrite_o <= MemWrite_o;
        ALUOp_o <= ALUOp_o;
        ALUSrc_o <= ALUSrc_o;
        RS1data_o <= RS1data_o;
        RS2data_o <= RS2data_o;
        Imm_o <= Imm_o;
        funct_o <= funct_o;
        RDaddr_o <= RDaddr_o;
        RS1addr_o <= RS1addr_o;
        RS2addr_o <= RS2addr_o;
    end 
    
end
endmodule