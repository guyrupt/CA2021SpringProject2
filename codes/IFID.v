module IFID (
    clk_i,
    start_i,
    stall,
    // in
    insIN,
    PC_i,
    Stall_i,
    Flush_i,
    // out 
    insOUT,
    PC_o
);

input clk_i, start_i, stall;
input Stall_i, Flush_i;
input [31:0] insIN, PC_i;

output [31:0] insOUT, PC_o;

reg [31:0] insOUT, PC_o;

always @(posedge clk_i) begin
    if (start_i) begin
        if (Stall_i | stall) begin
            insOUT <= insOUT;
            PC_o <= PC_o;
        end
        else if (Flush_i) begin
            insOUT <= 0;
            PC_o <= 0;
        end
        else begin
            insOUT <= insIN;
            PC_o <= PC_i;
        end
    end
    else begin
        insOUT <= insOUT;
        PC_o <= PC_o;
    end
        
    
end
endmodule