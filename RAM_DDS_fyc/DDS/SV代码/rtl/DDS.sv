`include "define.sv"
module DDS 
#(
 parameter WAVE_TYPE = "sin" //可配置为sin、squ、tri分别为正弦方波三角波
)

(
input logic clk,
input logic rst_n,
input logic [2:0] Fword,//频率控制字，控制每次步进的点数
input logic [`ADDR_WIDTH-1:0] Pword,//相位控制字，控制选取的初始点数（初始相位）
output logic [`ADDR_WIDTH-1:0] dout
);

logic [2:0] F_reg; //频率控制寄存器 存储Fword
always_ff @( posedge clk ) begin 
    F_reg <= Fword;  
end

logic [12:0] P_add; //相位累加器
always_ff @( posedge clk or negedge rst_n ) begin 
    if(!rst_n)
        P_add <= '0;
    else
        P_add <= P_add + F_reg;  
end

logic [11:0] P_reg; //相位控制寄存器 存储Pword
always_ff @( posedge clk ) begin 
        P_reg <= Pword; 
end

logic [11:0] P_now;
//logic [11:0] P_now_reg;
// always_ff @( posedge clk or negedge rst_n ) begin 
//     if (!rst_n)
//         P_now <= '0;
//     else
//         P_now <= P_add[12:3] + P_reg;   //将P_now限制在10bit  1024一循环
// end

//logic addr_reg;

always_ff @( posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        P_now <= '0;
    end
    else begin
    //P_now_reg <= P_add[12:3] + P_reg;   
    case (WAVE_TYPE)
    "tri": P_now <= (P_add[12:3] + P_reg)%1024;//{2'b00,(P_add[12:3])+P_reg};//
    "sin": P_now <= (P_add[12:3] + P_reg)%1024+1024;
    "squ": P_now <= ((P_add[12:3] + P_reg)%1024+2048);//{2'b10,(P_add[12:3])+P_reg};//
        default;
    endcase
end
end

logic wea = '0;
logic [`DATA_WIDTH-1:0] wr_data ='0;
dds_ram inst(
        .clk    (clk),
        .wea    (wea), 
        .addr   (P_now),
        .wr_data(wr_data),
        .re_data(dout)
);

endmodule