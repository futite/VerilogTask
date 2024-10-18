`timescale 1ns/1ps
module singel_port_tb;
logic clk;
logic wea=0; //???? 1?????0????
logic [9:0] addr='0;  //1024?????????10?
logic [31:0] wr_data = '0;
logic [31:0] re_data = 0;

initial begin
    clk=0;
    #10;
    forever begin
        #10 clk=~clk;
    end
end

// always_ff @( posedge clk ) begin //????????????????????
//     if(wea ==0) wr_data <= '0;
//     if(addr == 10'd1023)begin
//         addr <= '0;
//         wea <= ~wea;
//         if(wea == 1)
//     end
//     else addr <= addr +1'b1;
// end
  
// always_ff @( posedge clk ) begin //?????????????
//     if(wea == 1 & addr==0) 
//       wr_data <= 32'd1024;
//     else if (wea ==1 )
//         wr_data <= wr_data - 1'b1;
// end
task automatic rd_drv(input logic [9:0] r_addr);//????????????????????
    @(posedge clk);
    addr <= r_addr;
    wea <= 1'b0;
endtask //automatic
task automatic rd_data_task(input int cnt); //???????0?cnt
    for (int i = 0;i <cnt ;i++ ) begin
        rd_drv(i);
    end
    @(posedge clk); //???????
    wea <= 1'b1;
endtask //automatic

task automatic wr_drv(input logic [9:0] w_addr, input logic [31:0] w_data);
    @(posedge clk);            //???????????????????????????
    addr <= w_addr;
    wr_data <= w_data;
    wea <= 1'b1; 
endtask //automatic
task automatic wr_data_task(input int cnt); //??????
    for (int i = 0;i<cnt ;i++ ) begin
        wr_drv(i,i*i);
    end
    @(posedge clk); //?????(??10???)?????
   // #200; 
    wea <= 1'b0;
endtask //automatic

task automatic wr_drv1(input logic [9:0] w_addr, input logic [31:0] w_data);
    @(posedge clk);            //???????????????????????????
    addr <= w_addr;
    wr_data <= w_data;
    wea <= 1'b1; 
endtask //automatic
task automatic wr_data_task1(input int cnt); //??????
    for (int i = 0;i<cnt ;i++ ) begin
        wr_drv1(i,i+10);
    end
    @(posedge clk); //?????(??10???)?????
   // #200; 
    wea <= 1'b0;
endtask //automatic

// singel_port_ram ram_inst (
//   .clka(clk),    // input wire clka
//   .wea(wea),      // input wire [0 : 0] wea
//   .addra(addr),  // input wire [9 : 0] addra
//   .dina(wr_data),    // input wire [31 : 0] dina
//   .douta(re_data)  // output wire [31 : 0] douta
// );
singel_port_ram your_instance_name (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [9 : 0] addra
  .dina(wr_data),    // input wire [31 : 0] dina
  .douta(re_data)  // output wire [31 : 0] douta
);

//???.coe????????????????????????
initial begin
    #20;
    rd_data_task(20);
    // wr_data_task(6);
    // rd_data_task(6);
    // wr_data_task1(6);
    // rd_data_task(6);
    #20 $finish();
end

endmodule