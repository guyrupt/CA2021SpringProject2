module FU (
    IDEX_RS1_i,
    IDEX_RS2_i,
    EXMEM_RegWrite_i,
    EXMEM_RD_i,
    MEMWB_RegWrite_i,
    MEMWB_Rd_i,
    FwA_o,
    FwB_o
);


input [4:0] IDEX_RS1_i, IDEX_RS2_i;
input EXMEM_RegWrite_i;
input [4:0] EXMEM_RD_i;
input MEMWB_RegWrite_i;
input [4:0] MEMWB_Rd_i;
output reg [1:0] FwA_o, FwB_o;

always @(*) begin
    FwA_o <= 2'b0;
    FwB_o <= 2'b0;
    // EX hazard:
    if (EXMEM_RegWrite_i 
        && (EXMEM_RD_i != 0) 
        && (EXMEM_RD_i == IDEX_RS1_i)) begin
        FwA_o <= 2'b10;
    end
    if (EXMEM_RegWrite_i 
        && (EXMEM_RD_i != 0) 
        && (EXMEM_RD_i == IDEX_RS2_i)) begin
        FwB_o <= 2'b10;
    end
    // MEM hazard
    if (MEMWB_RegWrite_i 
        && (MEMWB_Rd_i !=0) 
        && !(EXMEM_RegWrite_i && (EXMEM_RD_i != 0) && (EXMEM_RD_i == IDEX_RS1_i)) 
        && (MEMWB_Rd_i == IDEX_RS1_i)) begin
        FwA_o <= 2'b01;
    end
    if (MEMWB_RegWrite_i 
        && (MEMWB_Rd_i !=0) 
        && !(EXMEM_RegWrite_i && (EXMEM_RD_i != 0) && (EXMEM_RD_i == IDEX_RS2_i)) 
        && (MEMWB_Rd_i == IDEX_RS2_i)) begin
        FwB_o <= 2'b01;
    end
end
endmodule