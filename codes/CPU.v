// `include "Control.v"
// `include "Adder.v"
// `include "PC.v"
// `include "Instruction_Memory.v"
// `include "Registers.v"
// `include "MUX32.v"
// `include "Sign_Extend.v"
// `include "ALU.v"
// `include "ALU_Control.v"
// `include "AND.v"
// `include "Data_Memory.v"
// `include "Equal.v"
// `include "EXMEM.v"
// `include "FU.v"
// `include "HDU.v"
// `include "IDEX.v"
// `include "IFID.v"
// `include "MEMWB.v"
// `include "MUX4.v"
// `include "ShiftLeft1.v"


module CPU
(
    clk_i, 
    rst_i,
    start_i,

    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

wire stall;

input [255:0] mem_data_i;
input mem_ack_i;
output [255:0] mem_data_o;
output [31:0] mem_addr_o;
output mem_enable_o;
output mem_write_o;
// Ports
input               clk_i;
input               rst_i;
input               start_i;
// Wires
wire [31:0] pc_o;
wire [31:0] pc_i_plus4;
wire [31:0] instr_o;
wire [6:0] Op_i;
wire [4:0] RS1addr_i;
wire [4:0] RS2addr_i;
wire [4:0] RDaddr_i;
wire [31:0] data_i;
wire [9:0] funct_i;
// wire for Control
wire [1:0] ALUOp_o;
wire ALUSrc_o;
wire RegWrite_o;
wire MemtoReg;
wire MemRead;
wire MemWrite;
wire Branch_o;
//
wire [31:0] RS1data_o;
wire [31:0] RS2data_o;
wire [31:0] data2_i;
wire [31:0] data_o;
wire [2:0] ALUCtrl_i;
wire [31:0] ALUresult;
/////////////////////////// more wires 
wire [31:0] pc_i;
wire [31:0] SL1_o;
wire [31:0] Addr_Branch;
wire [31:0] IFID_PC_o;
wire [31:0] instr2IFID;
wire Stall, Branch;
wire Eq_bit, PCWrite, NoOP;
// wires in EX 
wire IDEX_RegWrite, IDEX_MemtoReg, IDEX_MemRead, IDEX_MemWrite;
wire IDEX_ALUSrc;
wire [1:0] IDEX_ALUOp;
wire [31:0] IDEX_RS1data_o, IDEX_RS2data_o, IDEX_Imm;
wire [9:0] IDEX_funct_i;
wire [4:0] IDEX_RDaddr, IDEX_RS1addr, IDEX_RS2addr;
wire [1:0] FwA, FwB;
wire [31:0] muxout_rs1, muxout_rs2;
// wires in MEM
wire EXMEM_RegWrite, EXMEM_MemtoReg, EXMEM_MemRead, EXMEM_MemWrite;
wire [31:0] EXMEM_ALUResult, EXMEM_muxout_rs2;
wire [4:0] EXMEM_RDaddr;
wire [31:0] MEM_ReadData;
// wires in WB
wire MEMWB_RegWrite, MEMWB_MemtoReg;
wire [31:0] MEMWB_ALUResult, MEMWB_MemReadData;
wire [4:0] MEMWB_RDaddr;
wire [31:0] WB_out;



assign Op_i = instr_o[6:0];
assign RS1addr_i = instr_o[19:15];
assign RS2addr_i = instr_o[24:20];
assign RDaddr_i = instr_o[11:7];
assign data_i = instr_o[31:0];
assign funct_i = {instr_o[31:25],instr_o[14:12]};


Control Control(
    .Op_i       (Op_i),
    .ALUOp_o    (ALUOp_o),
    .ALUSrc_o   (ALUSrc_o),
    .RegWrite_o (RegWrite_o),
    .MemtoReg_o (MemtoReg),
    .MemWrite_o (MemWrite),
    .MemRead_o  (MemRead),
    .Branch_o   (Branch_o),
    .NoOP_i     (NoOP)
);



Adder Add_PC(
    .data1_in   (pc_o),
    .data2_in   (32'b100),
    .data_o     (pc_i_plus4)
);

Adder Add_Branch(
    .data1_in   (SL1_o),
    .data2_in   (IFID_PC_o),
    .data_o     (Addr_Branch)
);

ShiftLeft1 SL1_Branch(
    .in     (data_o),
    .out    (SL1_o)
);


PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .stall_i    (stall),
    .PCWrite_i  (PCWrite),
    .pc_i       (pc_i),
    .pc_o       (pc_o)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (pc_o), 
    .instr_o    (instr2IFID)
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (RS1addr_i),
    .RS2addr_i   (RS2addr_i),
    .RDaddr_i   (MEMWB_RDaddr), 
    .RDdata_i   (WB_out),
    .RegWrite_i (MEMWB_RegWrite), 
    .RS1data_o   (RS1data_o), 
    .RS2data_o   (RS2data_o) 
);


MUX32 MUX_ALUSrc(
    .data1_i    (muxout_rs2),
    .data2_i    (IDEX_Imm),
    .select_i   (IDEX_ALUSrc),
    .data_o     (data2_i)
);

MUX32 MUX_WB(
    .select_i   (MEMWB_MemtoReg),
    .data1_i    (MEMWB_ALUResult),
    .data2_i    (MEMWB_MemReadData),
    .data_o     (WB_out) 
);

MUX32 MUX_PC(
    .select_i   (Branch),
    .data1_i    (pc_i_plus4),
    .data2_i    (Addr_Branch),
    .data_o     (pc_i)
);

AND AND_Branch(
    .i1     (Branch_o),
    .i2     (Eq_bit),
    .out    (Branch)
);

Equal Equal_Branch(
    .i1     (RS1data_o),
    .i2     (RS2data_o),
    .out    (Eq_bit)
);

Sign_Extend Sign_Extend(
    .data_i     (data_i),
    .data_o     (data_o)
);

  

ALU ALU(
    .data1_i    (muxout_rs1),
    .data2_i    (data2_i),
    .ALUCtrl_i  (ALUCtrl_i),
    .data_o     (ALUresult),
    .Zero_o     ()
);



ALU_Control ALU_Control(
    .funct_i    (IDEX_funct_i),
    .ALUOp_i    (IDEX_ALUOp),
    .ALUCtrl_o  (ALUCtrl_i)
);

// Data_Memory Data_Memory(
//     .clk_i      (clk_i), 
//     .addr_i     (EXMEM_ALUResult), 
//     .MemRead_i  (EXMEM_MemRead),
//     .MemWrite_i (EXMEM_MemWrite),
//     .data_i     (EXMEM_muxout_rs2),
//     .data_o     (MEM_ReadData)

// );

dcache_controller dcache_controller(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    // data mem interface
    .mem_data_i (mem_data_i),
    .mem_ack_i  (mem_ack_i),
    .mem_data_o (mem_data_o),
    .mem_addr_o (mem_addr_o),
    .mem_enable_o(mem_enable_o),
    .mem_write_o (mem_write_o),
    // cpu interface
    .cpu_data_i     (EXMEM_muxout_rs2),   
    .cpu_addr_i     (EXMEM_ALUResult),     
    .cpu_MemRead_i  (EXMEM_MemRead), 
    .cpu_MemWrite_i (EXMEM_MemWrite), 
    .cpu_data_o     (MEM_ReadData), 
    .cpu_stall_o    (stall)
);

IFID IFID(
    .clk_i      (clk_i),
    .start_i    (start_i),
    .stall      (stall),
    // in   
    .insIN      (instr2IFID),
    .PC_i       (pc_o),
    .Stall_i    (Stall),
    .Flush_i    (Branch),
    // out 
    .insOUT     (instr_o),
    .PC_o       (IFID_PC_o)
);

IDEX IDEX(
    .clk_i      (clk_i),
    .start_i    (start_i),
    .stall      (stall),
    // in 
    .RegWrite_i     (RegWrite_o),
    .MemtoReg_i     (MemtoReg),
    .MemRead_i      (MemRead),
    .MemWrite_i     (MemWrite),
    .ALUOp_i        (ALUOp_o),
    .ALUSrc_i       (ALUSrc_o),
    .RS1data_i      (RS1data_o),
    .RS2data_i      (RS2data_o),
    .Imm_i          (data_o),
    .funct_i        (funct_i),
    .RDaddr_i       (RDaddr_i), 
    .RS1addr_i      (RS1addr_i),
    .RS2addr_i      (RS2addr_i),
    // out
    .RegWrite_o     (IDEX_RegWrite),
    .MemtoReg_o     (IDEX_MemtoReg),
    .MemRead_o      (IDEX_MemRead),
    .MemWrite_o     (IDEX_MemWrite),
    .ALUOp_o        (IDEX_ALUOp),      
    .ALUSrc_o       (IDEX_ALUSrc),
    .RS1data_o      (IDEX_RS1data_o),
    .RS2data_o      (IDEX_RS2data_o),
    .Imm_o          (IDEX_Imm),
    .funct_o        (IDEX_funct_i),
    .RDaddr_o       (IDEX_RDaddr),
    .RS1addr_o      (IDEX_RS1addr),
    .RS2addr_o      (IDEX_RS2addr)
);

EXMEM EXMEM(
    .clk_i(clk_i),
    .start_i    (start_i),
    .stall      (stall),
    //in
    .RegWrite_i     (IDEX_RegWrite),
    .MemtoReg_i     (IDEX_MemtoReg),
    .MemRead_i      (IDEX_MemRead),
    .MemWrite_i     (IDEX_MemWrite),
    .ALUresult_i    (ALUresult),
    .RS2data_i      (muxout_rs2),
    .RDaddr_i       (IDEX_RDaddr),
    //out
    .RegWrite_o     (EXMEM_RegWrite),
    .MemtoReg_o     (EXMEM_MemtoReg),
    .MemRead_o      (EXMEM_MemRead),
    .MemWrite_o     (EXMEM_MemWrite),
    .ALUresult_o    (EXMEM_ALUResult),
    .RS2data_o      (EXMEM_muxout_rs2),
    .RDaddr_o       (EXMEM_RDaddr)
);

MEMWB MEMWB(
    .clk_i(clk_i),
    .start_i    (start_i),
    .stall      (stall),
    // in
    .RegWrite_i     (EXMEM_RegWrite),
    .MemtoReg_i     (EXMEM_MemtoReg),
    .ALUresult_i    (EXMEM_ALUResult),
    .MemReadData_i  (MEM_ReadData),
    .RDaddr_i       (EXMEM_RDaddr),
    // out
    .RegWrite_o     (MEMWB_RegWrite),
    .MemtoReg_o     (MEMWB_MemtoReg),
    .ALUresult_o    (MEMWB_ALUResult),
    .MemReadData_o  (MEMWB_MemReadData),
    .RDaddr_o       (MEMWB_RDaddr)
);

HDU HDU(
    .RS1addr_i      (RS1addr_i),
    .RS2addr_i      (RS2addr_i),
    .PCWrite_o      (PCWrite),
    .Stall_o        (Stall),
    .NoOP_o         (NoOP),
    .RDaddr_i       (IDEX_RDaddr),
    .MemRead_i      (IDEX_MemRead)
);

FU FU(
    .IDEX_RS1_i     (IDEX_RS1addr),
    .IDEX_RS2_i     (IDEX_RS2addr),
    .EXMEM_RegWrite_i   (EXMEM_RegWrite),
    .EXMEM_RD_i         (EXMEM_RDaddr),
    .MEMWB_RegWrite_i   (MEMWB_RegWrite),
    .MEMWB_Rd_i         (MEMWB_RDaddr),
    .FwA_o              (FwA),
    .FwB_o              (FwB)
);

MUX4 MUX4_RS1(
    .out    (muxout_rs1),
    .i0     (IDEX_RS1data_o),
    .i1     (WB_out),    
    .i2     (EXMEM_ALUResult),
    .i3     (),
    .sel    (FwA)
);

MUX4 MUX4_RS2(
    .out    (muxout_rs2),
    .i0     (IDEX_RS2data_o),
    .i1     (WB_out),
    .i2     (EXMEM_ALUResult),
    .i3     (),
    .sel    (FwB)
);


endmodule

