`include "define.sv"
module TDP_RAM_tb;
    logic                           clka;
    logic                           wea;
    logic [$clog2(`DATA_DEPTH)-1:0] addra;
    logic [        `DATA_WIDTH-1:0] dina;
    logic [        `DATA_WIDTH-1:0] douta;

    logic                           clkb;
    logic                           web;
    logic [$clog2(`DATA_DEPTH)-1:0] addrb;
    logic [        `DATA_WIDTH-1:0] dinb;
    logic [        `DATA_WIDTH-1:0] doutb;


    initial begin  //A时钟
        clka = 0;
        #10;
        forever begin
            #10 clka = ~clka;
        end
    end

    initial begin  //B时钟
        clkb = 0;
        #10;
        forever begin
            #10 clkb = ~clkb;
        end
    end

    task automatic Awr_Bre_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //task1 ,A写B读
        @(posedge clka)begin
        wea   <= 1'b1;  //A port write
        dina  <= data;
        addra <= addr;
        end
        @(posedge clkb)begin
        web   <= 1'b0;  //B port read
        addrb <= addr;
        end
        
    endtask  //automatic
    task automatic Awr_Bre_data(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            Awr_Bre_drv(i, i + 100);
        end
    endtask  //automatic
    
//------------------------------------------------------------------------------------------------------
    task automatic A_w_r_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //A口同时读写
        @(posedge clka) begin
        addra <= addr;
        dina  <= data;
        wea <= 1'b1;
        end
    endtask  //automatic
    task automatic A_w_r_data(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            A_w_r_drv(i, i+10);
        end
    endtask  //automatic
//------------------------------------------------------------------------------------------------------
    task automatic A_w_r_drv1(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //A口同时读写
        @(posedge clka) begin
        addra <= addr;
        dina  <= data;
        wea <= 1'b1;
        end
    endtask  //automatic
    task automatic A_w_r_data1(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            A_w_r_drv(i, (i-10)*(i-10));
        end
       
    endtask  //automatic
//------------------------------------------------------------------------------------------------------
    task automatic A_re_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr);
    @(posedge clka)begin
        addra <= addr;
        wea <= 1'b0;
    end
        
    endtask //automatic
    task automatic A_re(input int start, input int cnt);

       for (int i = start; i < cnt; i++) begin
             A_re_drv(i);
       end 
    endtask //automatic
   //------------------------------------------------------------------------------------------------------
   //------------------------------------------------------------------------------------------------------
    task automatic B_w_r_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //A口同时读写
        @(posedge clkb) begin
        addrb <= addr;
        dinb  <= data;
        web <= 1'b1;
        end
    endtask  //automatic
    task automatic B_w_r_data(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            B_w_r_drv(i, i * i);
        end
    endtask  //automatic
     //------------------------------------------------------------------------------------------------------
    task automatic B_w_r_drv1(input logic [$clog2(`DATA_DEPTH)-1:0] addr, input logic [`DATA_WIDTH-1:0] data);  //A口同时读写
        @(posedge clkb) begin
        addrb <= addr;
        dinb  <= data;
        web <= 1'b1;
        end
    endtask  //automatic
    task automatic B_w_r_data1(input int start, input int cnt);
        for (int i = start; i < cnt; i++) begin
            B_w_r_drv(i, (i-5)*(i-5));
        end
    endtask  //automatic
//------------------------------------------------------------------------------------------------------
    task automatic B_re_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr);
    @(posedge clkb)begin
        addrb <= addr;
        web <= 1'b0;
    end   
    endtask //automatic
    task automatic B_re(input int start, input int cnt);

       for (int i = start; i < cnt; i++) begin
             B_re_drv(i);
       end 
    endtask //automatic
//------------------------------------------------------------------------------------------------------
    
    logic [ `DATA_WIDTH-1:0] mem  [`DATA_DEPTH-1:0];
    task automatic RAM_init_drv(input logic [$clog2(`DATA_DEPTH)-1:0] addr_init,input logic [`DATA_WIDTH-1:0] init_data);
        @(posedge clka);
        addra    <= addr_init;
        dina    <= init_data;
        wea       <= 1'b1;
    endtask  //automatic
    task automatic RAM_INIT;  //数据初始化
    $readmemh("D:/VerilogCodeSelf/RAM_DDS/RAM/ram_init_random.txt", mem);   
    for (int i = 0; i<`DATA_DEPTH;i++ ) begin
    RAM_init_drv(i,mem[i]);        
       end       
    endtask //automatic
//------------------------------------------------------------------------------------------------------
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
    endtask  //automatic

    true_dual_port_ram inst (
        .clka (clka),
        .wea  (wea),
        .addra(addra),
        .dina (dina),
        .douta(douta),
        .clkb (clkb),
        .web  (web),
        .addrb(addrb),
        .dinb (dinb),
        .doutb(doutb)
    );

    initial begin
       // Awr_Bre_data(0,25);
       // #20;
        //reset;
        //RAM_INIT;
       // #200;
        A_w_r_data(0,10);
       // #20;
        A_re(0,10);
        //#20;
        reset;
        // B_w_r_data(10,20);
        // B_re(10,20);
        A_w_r_data1(0,10);
        A_re(0,10);
       reset;
       #50
        Awr_Bre_data(0,10);
        reset;
       // B_re(0,10);
        #200;
       // #50;
        $finish;
    end
    
    initial begin
        B_w_r_data(10,20);
        B_re(10,20);
        reset;
        B_w_r_data1(10,20);
        B_re(10,20);
        //reset;
    end
    

endmodule
