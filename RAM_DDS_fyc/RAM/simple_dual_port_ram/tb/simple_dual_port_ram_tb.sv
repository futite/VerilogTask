`include "define.sv"
module SDP_RAM_tb;


    logic                           clka;
    logic                           clkb;
    logic                           wen;
    //logic                           ren; //输出端口有信号就能读
    logic [$clog2(`DATA_DEPTH)-1:0] w_addr;
    logic [$clog2(`DATA_DEPTH)-1:0] r_addr;
    logic [        `DATA_WIDTH-1:0] w_data;
    logic [        `DATA_WIDTH-1:0] r_data;


    initial begin  //写时钟
        clka = 0;
        #10;
        forever begin
            #10 clka = ~clka;
        end
    end

    initial begin  //读时钟
        clkb = 0;
        #10;
        forever begin
            #10 clkb = ~clkb;
        end
    end

    task automatic w_drv(input logic [$clog2(`DATA_DEPTH)-1:0] drv_addr, input logic [`DATA_WIDTH-1:0] w_drv_data);  //写任务
        @(posedge clka);
        w_addr <= drv_addr;
        w_data <= w_drv_data;
        wen    <= 1'b1;
    endtask  //automatic
    task automatic w_data_task(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            w_drv(i, i + 10);
        end
        @(posedge clka) wen <= 1'b0;
    endtask  //automatic

    task automatic r_drv(input logic [$clog2(`DATA_DEPTH)-1:0] r_drv_addr);  //读任务
        @(posedge clkb);
        r_addr <= r_drv_addr;
        // ren <= 1'b1;
    endtask  //automatic
    task automatic r_data_task(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            r_drv(i);
        end
    endtask  //automatic

    task automatic w_r_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //同时读写
        @(posedge clka or posedge clkb) wen <= 1'b1;
        //ren <= 1'b1;
        w_addr <= addr;
        r_addr <= addr;
        w_data <= data;
    endtask  //automatic
    task automatic w_r_data(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            w_r_drv(i, i * i);
        end
        @(posedge clka) wen <= 1'b0;
    endtask  //automatic

    task automatic w_r_drv1(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //同时读写，写入内容改变
    @(posedge clka or posedge clkb) wen <= 1'b1;
    //ren <= 1'b1;
    w_addr <= addr;
    r_addr <= addr;
    w_data <= data;
    endtask  //automatic
    task automatic w_r_data1(input int start, input int cnt);
    for (int i = start; i < cnt; i++) begin
        w_r_drv(i, (i-5)*(i-5));
    end
    @(posedge clka) wen <= 1'b0;
    endtask  //automatic



    logic [ `DATA_WIDTH-1:0] mem  [`DATA_DEPTH-1:0];
    
    task automatic RAM_init_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr_init,input logic [`DATA_WIDTH-1:0] init_data);
        @(posedge clka);
        w_addr    <= addr_init;
        w_data    <= init_data;
        wen       <= 1'b1;
    endtask  //automatic
    task automatic RAM_INIT;  //数据初始化
    $readmemh("D:/VerilogCodeSelf/RAM_DDS/RAM/ram_init_random.txt", mem);   
    for (int i = 0; i<`DATA_DEPTH;i++ ) begin
    RAM_init_drv(i,mem[i]);        
       end       
    endtask //automatic

    task automatic reset;     //信号复位
        @(posedge clka or posedge clkb);
        wen    <= '0;
        // ren <= '0;
        w_addr <= '0;
        r_addr <= '0;
    endtask  //automatic


    simple_dual_port_ram inst (
        .clka  (clka),
        .clkb  (clkb),
        .wen   (wen),
        //.ren   (ren),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .w_data(w_data),
        .r_data(r_data)
    );

    initial begin
        //r_data_task(0, 8);
        //w_data_task(0, 8);
        //reset;
        //r_data_task(0, 8);
       // RAM_INIT;
       // #500;
       // reset;
        //r_data_task(0,200);
      //  reset;
        w_r_data(0, 10);
        
        // #20;
        r_data_task(0, 10);
        reset;
        w_r_data1(0, 10);
        // w_data_task(10, 15);
        reset;
        r_data_task(0, 10);
        // reset;
        #50;
        $finish;
    end



endmodule
