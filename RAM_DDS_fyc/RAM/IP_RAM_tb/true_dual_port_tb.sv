`timescale 1ns/1ps

module true_dual_port_tb ;
logic clka;
logic clkb;
logic wea=0;//1写0读
logic web=0;
logic [9:0] addra=0;
logic [9:0] addrb=0;
logic [31:0] dina=0;
logic [31:0] dinb=0;
logic [31:0] douta;
logic [31:0] doutb;

initial begin //A端口时钟
    clka=0;
    #10;
    forever begin
        #10 clka=~clka;
    end
end

initial begin //B端口时钟
    clkb=0;
    #10;
    forever begin
        #10 clkb=~clkb;
    end
end

task automatic Awr_Bre_drv(input logic [9:0]addr, input logic [31:0] data);//task1 ,A写B读
    @(posedge clka or posedge clkb);
    wea <= 1'b1;//A port write
    web <= 1'b0;//B port read
    addra <= addr;
    addrb <= addr;
    dina <= data;   
endtask //automatic
task automatic Awr_Bre_data(input int cnt);
  for ( int i = 0 ; i < cnt ; i++ ) begin
     Awr_Bre_drv(i,i+100);
  end  
endtask //automatic


task automatic Bwr_Are_drv(input logic [9:0]addr, input logic [31:0] data);//task1 ,A写B读
    @(posedge clka or posedge clkb);
    wea <= 1'b0;//A port read
    web <= 1'b1;//B port write
    addra <= addr;
    addrb <= addr;
    dinb <= data;   
endtask //automatic
task automatic Bwr_Are_data(input int cnt);
  for ( int i = 0 ; i < cnt ; i++ ) begin
     Bwr_Are_drv(i,i+1);
  end  
endtask //automatic


task automatic Awr_re_drv(input logic [9:0] addr , input logic [31:0] data);//同时读写
        @(posedge clka or posedge clkb)
        wea <= 1'b1;
        addra <= addr;
        //addrb <= addr;
        dina <= data; 
endtask //automatic
task automatic Awr_re_data(input int cnt);
    for (int i = 0; i<cnt ; i++) begin
        Awr_re_drv(i,i+50); 
    end   
endtask //automatic


task automatic Bwr_re_drv(input logic [9:0] addr , input logic [31:0] data);//同时读写
        @(posedge clka or posedge clkb)
        web <= 1'b1;
        addrb <= addr;
        //addrb <= addr;
        dinb <= data; 
endtask //automatic
task automatic Bwr_re_data(input int cnt);
    for (int i = 0; i<cnt ; i++) begin
        Bwr_re_drv(i,i+17); 
    end
       
endtask //automatic

task automatic A_fight_drv(input logic [9:0] addr,input logic [31:0] data);
    @(posedge clka)begin       
      wea <= ~wea;
      addra <= addr; 
      dina <= data;
    end
      //wea <= 1'b0;
endtask //automatic
task automatic A_fight(input int start,input int cnt);
    for (int i = start; i<cnt ; i++ ) begin
    A_fight_drv(i,i+2);     
    end   
endtask //automatic

task automatic B_fight_drv(input logic [9:0] addr,input logic [31:0] data);
    @(posedge clkb)begin       
      web <= ~web;
      addrb <= addr; 
      dinb <= data;
    end
     // web <= 1'b0;
endtask //automatic
task automatic B_fight(input int start,input int cnt);
    for (int i = start; i<cnt ; i++ ) begin
    B_fight_drv(i,i+20);     
    end   
endtask //automatic
task automatic reset;     //信号复位
    @(posedge clka )begin
    wea    <= '0;
    addra  <= '0;
    dina   <= '0;
    end
    @(posedge clkb) begin
    web    <= '0;
    addrb  <= '0;
    dinb   <= '0;
    end
endtask
true_dual_port_ram inst (
  .clka(clka),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(douta),  // output wire [31 : 0] douta

  .clkb(clkb),    // input wire clkb
  .web(web),      // input wire [0 : 0] web
  .addrb(addrb),  // input wire [9 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

initial begin
    //Awr_Bre_data(10);
    //reset;
    
    A_fight(0,10);
    B_fight(10,20);
    #30;
   // 
    #30;
   //   Awr_re_data(100);
    #30;
   //Bwr_re_data(100);
   // Bwr_Are_data(100);
    #50;
     
    $finish();
end


endmodule