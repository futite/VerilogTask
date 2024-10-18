`timescale 1ns/1ps
module simple_dual_port_tb;
logic clka;
logic clkb;
logic wea=0; //使能信号 1为写使能，0为读使能
logic [9:0] addra='0;  //1024个数据，地址对应为10位
logic [9:0] addrb='0;  //1024个数据，地址对应为10位
logic [31:0] dina = '0;
logic [31:0] doutb;

initial begin //写时钟
    clka=0;
    #10;
    forever begin
        #10 clka=~clka;
    end
end

initial begin //读时钟
    clkb=0;
    #10;
    forever begin
        #10 clkb=~clkb;
    end
end

task automatic rd_drv(input logic [9:0] r_addr);//读任务
    @(posedge clkb);
    addrb <= r_addr;
    wea <= 1'b0; 
endtask //automatic
task automatic rd_data(input int cnt);
    for (int i = 0 ; i<cnt ; i++ ) begin
        rd_drv(i);   
    end
    @(posedge clkb)
    wea <= 1'b1;
endtask //automatic

task automatic wr_drv(input logic [9:0] w_addr, input logic [31:0] w_data);//写任务
    @(posedge clka)
    addra <= w_addr;
    dina  <= w_data;
    wea   <= 1'b1;
endtask //automatic
task automatic wr_data(input int cnt);
    for (int i = 0; i< cnt ; i++ ) begin
        wr_drv(i,i*i);
    end
    @(posedge clka)    
    wea <= 1'b0;
endtask //automatic

task automatic wr_rd_drv(input logic [9:0] addr , input logic [31:0] data);//同时读写
        @(posedge clka or posedge clkb)
        wea <= 1'b1;
        addra <= addr;
        addrb <= addr;
        dina <= data; 
endtask //automatic
task automatic wr_rd_data(input int cnt);
    for (int i = 0; i<cnt ; i++) begin
        wr_rd_drv(i,i+10); 
    end   
endtask //automatic

task automatic wr_rd_drv1(input logic [9:0] addr , input logic [31:0] data);//同时读写
        @(posedge clka or posedge clkb)
        wea <= 1'b1;
        addra <= addr;
        addrb <= addr;
        dina <= data; 
endtask //automatic
task automatic wr_rd_data1(input int cnt);
    for (int i = 0; i<cnt ; i++) begin
        wr_rd_drv1(i,i+20); 
    end   
endtask //automatic


blk_mem_gen_0 simple_dual_port_ram_inst (
  .clka(clka),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .clkb(clkb),    // input wire clkb
  .addrb(addrb),  // input wire [9 : 0] addrb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

initial begin
    //
    //#100;
   
   // wr_data(6);
    //rd_data(6);
    wr_rd_data(6);
    rd_data(6);
    wr_rd_data1(6);
    rd_data(6);



    #20;
    $finish();
end

endmodule