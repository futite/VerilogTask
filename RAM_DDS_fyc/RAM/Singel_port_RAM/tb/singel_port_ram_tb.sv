`include "define.sv"

module singel_port_ram_tb;
    logic                           clk;
    //logic rst_n;
    logic                           wea;
    logic [$clog2(`DATA_DEPTH)-1:0] addr;
    logic [        `DATA_WIDTH-1:0] wr_data;
    logic [        `DATA_WIDTH-1:0] re_data;


    initial begin
        clk = 0;
        #10;
        forever begin
            #10 clk = ~clk;
        end
    end

    task automatic rd_drv(input logic [$clog2(`DATA_DEPTH)-1:0] r_addr);  //读操作
        @(posedge clk);
        addr <= r_addr;
        wea  <= 1'b0;
    endtask  //automatic
    task automatic rd_data_task(input int s, input int cnt);
        for (int i = s; i < cnt; i++) begin
            rd_drv(i);
        end
        @(posedge clk);
        wea <= 1'b1;
    endtask  //automatic

    task automatic wr_drv(input logic [$clog2(`DATA_DEPTH)-1:0] w_addr, input logic [`DATA_WIDTH-1:0] w_data);  //写操作
        @(posedge clk);
        addr    <= w_addr;
        wr_data <= w_data;
        wea     <= 1'b1;
    endtask  //automatic
    task automatic wr_data_task(input int s, input int cnt);
        for (int i = s; i < cnt; i++) begin
            wr_drv(i, i * i);
        end
        @(posedge clk);
        // #200; 
        wea <= 1'b0;
    endtask  //automatic


    singel_port_ram inst (
        .clk    (clk),
        //.rst_n(rst_n),
        .wea    (wea),
        .addr   (addr),
        .wr_data(wr_data),
        .re_data(re_data)
    );

    logic [ `DATA_WIDTH-1:0] mem     [`DATA_DEPTH-1:0];
    initial begin
    $readmemh("D:/VerilogCodeSelf/RAM_DDS/RAM/ram_init_random.txt", mem);
    end
    task automatic RAM_init_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr_init,input logic [`DATA_WIDTH-1:0] init_data);
        @(posedge clk);
        addr    <= addr_init;
        wr_data <= init_data;
        wea     <= 1'b1;
    endtask  //automatic
    task automatic RAM_INIT;  //数据初始化
       for (int i = 0; i<`DATA_DEPTH;i++ ) begin
        RAM_init_drv(i,mem[i]);        
       end       
    endtask //automatic
    


    initial begin
        // rst_n = 0;
         RAM_INIT;
         #2000;
        //  rst_n =1 ;
         wr_data_task(0,6);    
         rd_data_task(0,6);
        // wr_data_task(5,9);
        //  rd_data_task(5,9);
        #50;
        $finish;

    end



endmodule
