`timescale 1ns/1ps
`include "define.sv"
module sync_fifo_tb ();
  //  parameter DATA_WIDTH = 'd32;
  //  parameter DATA_DEPTH = 'd512;
    logic                  clk;
    logic [`DATA_WIDTH-1:0] data_in;
    logic                  wr_en=0;
    logic                  rd_en=0;
    logic                  rst_n;
    logic [`DATA_WIDTH-1:0] data_out;
    logic                  full=0;
    logic                  empty;
    logic                pro_full;
    logic                pro_empty;


initial begin
    clk = 0;
    
    forever #10 clk=~clk;
end

task automatic wr(input int cnt);//input logic [DATA_DEPTH-1:0] data);
for (int i=0; i<cnt; i++ ) begin
    wr_en =1;
    data_in = i+512;
    #20;
end 
endtask //automatic

task automatic rd();
   rd_en <=1;
endtask //automatic

task automatic wr1(input int cnt);//input logic [DATA_DEPTH-1:0] data);
for (int i=0; i<cnt; i++ ) begin
    wr_en =1;
    data_in = i+100;
    #20;
end 
endtask 

initial begin
    rst_n=0;
    #10;
    rst_n=1;
   // wr_en=1; 
    wr(512);
    wr_en=0;
    rd;
    #20000;
    rd_en=0;
    wr1(512);
    wr_en=0;
    rd;
    #20000;
    rd_en=0;
    wr(512);
    wr_en=0;
    rd;
    #20;
    
    //$finish;
end






    sync_fifo
    // #(
    // .DATA_DEPTH(DATA_DEPTH),
    // .DATA_WIDTH(DATA_WIDTH)
    // )
    inst 
    (
    .clk(clk),
    .data_in(data_in),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .rst_n(rst_n),
    .data_out(data_out),
    .full(full),
    .empty(empty),
    .pro_full(pro_full),
    .pro_empty(pro_empty)
    );

endmodule
