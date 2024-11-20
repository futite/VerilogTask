module async_fifo #(
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32  ,
    parameter PTR_WIDTH  = $clog2(DATA_DEPTH)
)(
input logic wr_clk,
input logic wr_rst_n,
input logic wr_en,
input logic [DATA_WIDTH-1:0] wr_data,
input logic rd_clk,
input logic rd_rst_n,
input logic rd_en,
output logic [DATA_WIDTH-1:0] rd_data,
output logic fifo_full,
output logic fifo_empty
); 

logic [DATA_WIDTH-1:0] mem [DATA_DEPTH-1:0];
logic [PTR_WIDTH:0] wr_ptr;
logic [PTR_WIDTH-1:0] wr_addr;
//写指针计数
always_ff @( posedge wr_clk or negedge wr_rst_n ) begin
    if(!wr_rst_n)
        wr_ptr<=0;
    else if(wr_en & ~fifo_full)
        wr_ptr<=wr_ptr+1;
    else
        wr_ptr<=wr_ptr;
end
assign wr_addr=wr_ptr[PTR_WIDTH-1:0];
//写数据
always_ff @( posedge wr_clk or negedge wr_rst_n ) begin 
    if(!wr_rst_n)
        mem[wr_addr] <= 0;
    else if(wr_en & ~fifo_full)
        mem[wr_addr] <= wr_data;
    else
        mem[wr_addr] <= mem[wr_addr];
end

logic [PTR_WIDTH:0] rd_ptr;
logic [PTR_WIDTH-1:0] rd_addr;
//读指针计数
always_ff @( posedge rd_clk or negedge rd_rst_n ) begin
    if(!rd_rst_n)
        rd_ptr <= 0;
    else if(rd_en & ~fifo_empty)
        rd_ptr <= rd_ptr + 1;
    else
        rd_ptr <= rd_ptr;   
end
assign rd_addr = rd_ptr[PTR_WIDTH-1:0];
//读数据
always_ff @( posedge rd_clk or negedge rd_rst_n ) begin 
    if(!rd_rst_n)
        rd_data <= 0;
    else if(rd_en & ~fifo_empty)
        rd_data <= mem[rd_addr];
    else rd_data <= rd_data;
end
//写指针打两拍到读时钟
logic [PTR_WIDTH:0] wr_ptr_r0;
logic [PTR_WIDTH:0] wr_ptr_r1;
always_ff @( posedge rd_clk or negedge rd_rst_n ) begin
    if(!rd_rst_n)
        {wr_ptr_r0,wr_ptr_r1} <= '0;
    else
        {wr_ptr_r0,wr_ptr_r1} <= {wr_ptr,wr_ptr_r0};    
end

//读指针打两拍同步到写时钟
logic [PTR_WIDTH:0] rd_ptr_r0;
logic [PTR_WIDTH:0] rd_ptr_r1;
always_ff @( posedge wr_clk or negedge wr_rst_n ) begin 
    if(!rd_rst_n)
          {rd_ptr_r0,rd_ptr_r1} <= '0;
    else
          {rd_ptr_r0,rd_ptr_r1} <= {rd_ptr,rd_ptr_r0};     
end

//满判断
always_comb begin 
    if(!wr_rst_n)
        fifo_full  <=0;
    else if(wr_ptr=={~rd_ptr_r1[PTR_WIDTH],rd_ptr_r1[PTR_WIDTH-1:0]})//相差最高位：1024
        fifo_full<=1;
    else
        fifo_full<=0;
end
//空判断
always_comb begin
    if(!rd_rst_n)
        fifo_empty <=0;
    else if(rd_ptr==wr_ptr_r1)
        fifo_empty<=1;
    else
        fifo_empty<=0;
end

endmodule