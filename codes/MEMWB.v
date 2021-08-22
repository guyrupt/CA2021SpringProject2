module MEMWB (
    clk_i,
    start_i,
    stall,
    // in
    RegWrite_i,
    MemtoReg_i,
    ALUresult_i,
    MemReadData_i,
    RDaddr_i,
    // out
    RegWrite_o,
    MemtoReg_o,
    ALUresult_o,
    MemReadData_o,
    RDaddr_o
);

input clk_i, start_i, stall;
input RegWrite_i, MemtoReg_i;
input [31:0] ALUresult_i, MemReadData_i;
input [4:0] RDaddr_i;

output RegWrite_o, MemtoReg_o;
output [31:0] ALUresult_o, MemReadData_o;
output [4:0] RDaddr_o;

reg RegWrite_o, MemtoReg_o;
reg signed [31:0] ALUresult_o, MemReadData_o;
reg [4:0] RDaddr_o;

always @(posedge clk_i) begin
    if (start_i && !stall) begin
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
        ALUresult_o <= ALUresult_i;
        MemReadData_o <= MemReadData_i;
        RDaddr_o <= RDaddr_i;
    end
    else begin
        RegWrite_o <= RegWrite_o;
        MemtoReg_o <= MemtoReg_o;
        ALUresult_o <= ALUresult_o;
        MemReadData_o <= MemReadData_o;
        RDaddr_o <= RDaddr_o;
    end
end
endmodule