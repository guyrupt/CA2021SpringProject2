module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   reg [24:0]    tag_o;
output   reg [255:0]   data_o;
output   reg           hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];    
reg      [255:0]   data[0:15][0:1];
reg      lru [0:15][0:1];

integer            i, j;
// Wire for tag
wire CPU_dirty;
wire CPU_valid;
wire [22:0] CPU_tag;

assign CPU_dirty = tag_i[23];
assign CPU_valid = tag_i[24];
assign CPU_tag = tag_i[22:0];

// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
                lru[i][j] <= 1'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // 2-way associative cache + LRU
        if (~CPU_dirty) begin // if data comes from data memory
            if (lru[addr_i][0] == 0) begin
                tag[addr_i][0] <= tag_i;
                data[addr_i][0] <= data_i;
                lru[addr_i][0] <= 1'b1;
                lru[addr_i][1] <= 1'b0;
            end
            else begin
                tag[addr_i][1] <= tag_i;
                data[addr_i][1] <= data_i;
                lru[addr_i][1] <= 1'b1;
                lru[addr_i][0] <= 1'b0;
            end
        end
        else begin 
            if (tag[addr_i][0][24] && (tag[addr_i][0][22:0] == CPU_tag)) begin
                tag[addr_i][0] <= tag_i;
                data[addr_i][0] <= data_i;
                lru[addr_i][0] <= 1'b1;
                lru[addr_i][1] <= 1'b0;
            end
            else begin
                tag[addr_i][1] <= tag_i;
                data[addr_i][1] <= data_i;
                lru[addr_i][1] <= 1'b1;
                lru[addr_i][0] <= 1'b0;
            end
        end
    end
end

// Read Data      
//always @(posedge clk_i or posedge rst_i) begin
always @(*) begin
    if (enable_i) begin //read hit in associate 0
        if (tag[addr_i][0][24] && (tag[addr_i][0][22:0] == CPU_tag)) begin
            tag_o <= tag_i;
            data_o <= data[addr_i][0];
            lru[addr_i][0] <= 1'b1;
            lru[addr_i][1] <= 1'b0;
            hit_o <= 1'b1;
        end
        else if (tag[addr_i][1][24] && (tag[addr_i][1][22:0] == CPU_tag)) begin
            tag_o <= tag_i;
            data_o <= data[addr_i][1];
            lru[addr_i][1] <= 1'b1;
            lru[addr_i][0] <= 1'b0;
            hit_o <= 1'b1;
        end
        else begin // read miss
            if (lru[addr_i][0] == 0) begin
                tag_o <= tag[addr_i][0];
                data_o <= data[addr_i][0];
            end
            else begin
                tag_o <= tag[addr_i][1];
                data_o <= data[addr_i][1];
            end
            hit_o <= 1'b0;
        end
    end 
    else begin
        tag_o <= 23'b0;
        data_o <= 256'b0;
        hit_o <= 1'b0;
    end
end
// debug
wire [24:0] tag_index0_0;
wire [255:0] data_index0_0;
wire [24:0] tag_index0_1;
wire [255:0] data_index0_1;
wire lru_index0_0, lru_index0_1;

assign lru_index0_0 = lru[0][0];
assign lru_index0_1 = lru[0][1];
assign tag_index0_0 = tag[0][0];
assign data_index0_0 = data[0][0];
assign tag_index0_1 = tag[0][1];
assign data_index0_1 = data[0][1];

endmodule
