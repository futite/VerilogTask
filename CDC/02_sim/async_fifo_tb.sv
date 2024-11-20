`timescale 1ns/1ps
module async_fifo_tb #(
    parameter DATA_DEPTH = 1024,
    parameter DATA_WIDTH = 32  ,
    parameter PTR_WIDTH  = 10
);
logic wr_clk;
logic wr_rst_n;
logic wr_en=0;
logic [DATA_WIDTH-1:0] wr_data=0;
logic rd_clk;
logic rd_rst_n;
logic rd_en=0;
logic [DATA_WIDTH-1:0] rd_data;
logic fifo_full;
logic fifo_empty;

async_fifo uut (
    .wr_clk(wr_clk),
    .wr_rst_n(wr_rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty)
);

// always #5   wr_clk=~wr_clk;
// always #15  rd_clk=~rd_clk;

always #2.5   wr_clk=~wr_clk;
always #15  rd_clk=~rd_clk;
task automatic wr(integer cnt);
   // for (int i = 0; i<cnt; i++) begin
    //@(posedge wr_clk)begin
    repeat(cnt) begin
    wr_en=1;  
    @(posedge wr_clk) begin    
    wr_data={$urandom_range(0,99)};
                      end
    end
    @(posedge wr_clk)
    wr_en=0;
   // end
endtask //automatic



initial begin
wr_rst_n=0;
rd_rst_n=0;
wr_clk=0;
rd_clk=0;
#10;
wr_rst_n=1;
rd_rst_n=1;
#10;
wr(7);
#10;
rd_en=1;
#400;
rd_en=0;
#20;
rd_en=1;
wr(7);
// #20;//等待写完
// rd();
// #400;//等待读完
// rd_en=0;
// #20;
// rd_en=1;
// wr(7);//同时读写
// #400;
// //$finish;
end



endmodule