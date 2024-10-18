`timescale 1ns / 1ps

module dds_tb;
    logic        clk;
    logic        rst_n;
    logic [ 2:0] Fword;  //频率控制字，控制每次步进的点数
    logic [11:0] Pword;  //相位控制字，控制选取的初始点数（初始相位）
    logic [11:0] dout;
    logic [ 2:0] Fword1;  //频率控制字，控制每次步进的点数
    logic [11:0] Pword1;  //相位控制字，控制选取的初始点数（初始相位）
    logic [11:0] dout1;
    logic [ 2:0] Fword2;  //频率控制字，控制每次步进的点数
    logic [11:0] Pword2;  //相位控制字，控制选取的初始点数（初始相位）
    logic [11:0] dout2;

    initial begin
        clk = 0;
        #10;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 0;
        Fword = '0;
        Pword = '0;
        Fword1 = '0;
        Pword1 = '0;
        Fword2 = '0;
        Pword2 = '0;
        #200;
        rst_n = 1;
        #200;
        Fword = 3'd1;
        Pword = 12'd256;
        Fword1 =3'd1;
        Pword1 =12'd0;
        Fword2 = 3'd4;
        Pword2 = 12'd512;
        #200;
        //Fword = 3'd1;
        //Pword = 12'd0;
        #100000;
        //$finish;
    end
    



    DDS #(
        .WAVE_TYPE("sin")
    ) sin_inst (
        .clk  (clk),
        .rst_n(rst_n),
        .Fword(Fword),
        .Pword(Pword),
        .dout (dout)
    );
     
    DDS #(
        .WAVE_TYPE("squ")
    ) squ_inst (
        .clk  (clk),
        .rst_n(rst_n),
        .Fword(Fword1),
        .Pword(Pword1),
        .dout (dout1)
    );

    DDS #(
        .WAVE_TYPE("tri")
    ) tri_inst (
        .clk  (clk),
        .rst_n(rst_n),
        .Fword(Fword2),
        .Pword(Pword2),
        .dout (dout2)
    );

endmodule
