module Sign_Extend (
    data_i,
    data_o
);
input [31:0] data_i;
output [31:0] data_o;

reg signed [31:0] data_o;
wire signed [11:0] imm12;
assign imm12 = data_i[31:20];
wire signed [4:0] srai_imm;
assign srai_imm = data_i[24:20];
wire signed [11:0] sw_imm;
assign sw_imm = {data_i[31:25], data_i[11:7]};
wire signed [11:0] beq_imm;
assign beq_imm = {data_i[31], data_i[7], data_i[30:25], data_i[11:8]};


`define ADDI 10'b0000010011
`define SRAI 10'b1010010011
`define LW 10'b0100000011
`define SW 10'b0100100011
`define BEQ 10'b0001100011


wire [9:0] funct3_opcode;
assign funct3_opcode = {data_i[14:12], data_i[6:0]};



// assign data_o = {{20{data_i[11]}},data_i};
always @(*) begin
    case (funct3_opcode)
    `ADDI: data_o <= {{20{imm12[11]}}, imm12};
    `SRAI: data_o <= {{27{srai_imm[4]}}, srai_imm};
    `LW: data_o <= {{20{imm12[11]}}, imm12};
    `SW: data_o <= {{20{sw_imm[11]}}, sw_imm};
    `BEQ: data_o <= {{20{beq_imm[11]}}, beq_imm};
endcase
end
endmodule