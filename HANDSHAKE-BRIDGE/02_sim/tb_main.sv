`timescale 1ns/1ps
`include "define.sv"
module tb_main ();
  //  parameter DATA_WIDTH = 'd32;
  //  parameter DATA_DEPTH = 'd512;
    logic                  clk;
    logic [`DATA_WIDTH-1:0] data_in=2'd0;
    logic                  wr_en=0;
    logic                  send_en=0;
    logic                  rst_n;
    //logic                  receiver_en=0;
    logic [`DATA_WIDTH-1:0] data_receiver;
    logic ready='0;
    logic ack='0;
    logic [`DATA_WIDTH-1:0] data_send = '0;
   // logic [`DATA_WIDTH-1:0] data_out = '0;
    logic full, empty, full_1, empty_1;
    logic req;
    logic valid=0;
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

task automatic send_to_B();
   send_en <=1;
endtask //automatic

task automatic wr1(input int cnt);//input logic [DATA_DEPTH-1:0] data);
for (int i=0; i<cnt; i++ ) begin
    wr_en =1;
    data_in = i+100;
    #20;
end 
endtask 

task automatic reset();
  ready=0;
  ack=0;
  send_en=0;
endtask //automatic

initial begin
    rst_n=1;
    #10;
    rst_n=0;
    #20;
    rst_n=1;
end
initial begin
    #390;
    send_en=1;
    ready=1;
    #20;

    ready=0;
    send_en=0;
end
initial begin
    //rst_n=0;
    #30;
    //rst_n=1;
   // wr_en=1; 
    wr(8);
    wr_en=0;
    //send_to_B;
    //#20;
    send_en=1;
    ready=1;
    #20;

    #60;
    #40;
    ready=0;
    send_en=0;
   // out_ready=1;
    #20;
    //ready=0;
    //#400;
    ack=1;
     #60;
     #60;
     ack=1;
     #60;
     #60;
     //ready=1;
     //#20;
     //ready=0;
     //#20;
     ack=1;
     #120;
     ack=1;
     #120;
     ack=1;
     #80;
     ack=1;
     #60;
     ack=1;
    


    // wr1(10);
    // wr_en=0;
     //send_en=1;
    // ready=1;
    // #200;
    $finish;
end


    //logic ack;
    sender inst1 (
        .clk      (clk),
        .data_in  (data_in),
        .wr_en    (wr_en),
        .send_en  (send_en),
        .rst_n    (rst_n),
        .ready    (ready),      //来自bridge输出
        .data_send(data_send),
        .full     (full),
        .empty    (empty),
        // output logic                pro_full,
        // output logic                pro_empty,
        .valid    (valid)
    );

    bridge inst2 (
        .clk     (clk),
        .reset   (rst_n),
        .valid   (valid),      //Sender发到bridge的有效信号
        .ready   (ready),      //bridge返回给bridge的准备信号
        .req     (req),        //bridge发送给receiver的请求信号
        .ack     (ack),        //Receiver返回给bridge的确认信号
        .data_in (data_send),
        .data_receiver(data_receiver)
    );

    receiver inst3 (
        .clk          (clk),
        .data_receiver(data_receiver),
        .read_en      (read_en),
       // .receiver_en  (receiver_en),
        .rst_n        (rst_n),
        .req          (req),
       // .data_show(data_show),
        .full         (full_1),
        .empty        (empty_1),
        // output logic                pro_full,
        // output logic                pro_empty,
        .ack          (ack)
    );




    

endmodule
