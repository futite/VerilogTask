`include "define.sv"
module tx_clk_gen
// #(
// parameter CLK_FREQUENCE = 50_000_000 ,
//           BAUD_RATE =9600
// )
(
   input logic clk,
   input logic rst_n, 
   input logic tx_done,
   input logic tx_start,
   output logic bps_clk
);
localparam  BPS_CNT = `CLK_FREQUENCE/`BAUD_RATE-1 ,//传输一bit数据所需要的系统时钟周期，计数5027
            BPS_WD  = $clog2(BPS_CNT);
logic [BPS_WD-1:0] count;

typedef enum logic [1:0] {
      IDLE,
      TRANSMITTER
} state_t;
state_t c_state, n_state;
//FSM-1
always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n)
        c_state <= IDLE;
    else 
        c_state <= n_state;
end

//FSM-2 状态判断
always_comb begin 
    case (c_state)
       IDLE        : n_state = tx_start ? TRANSMITTER : IDLE;
       TRANSMITTER : n_state = tx_done  ? IDLE : TRANSMITTER;
       default : n_state = IDLE ;
    endcase
end

//FSM-3 数据处理,计数条件判断
always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n)
      count <= {BPS_WD{1'b0}};
    else if (c_state==IDLE)
      count <= {BPS_WD{1'b0}};
    else begin //上述两个条件不满足时处于发送状态
        if (count == BPS_CNT) //计数达到最大值
           count <= '0;
        else
            count <= count + 1'b1;       
    end 
end

//FSM-4 数据发送 处理output信号
always_ff @( posedge clk or negedge rst_n ) begin 
    if (rst_n == 1'b0)
       bps_clk <= 1'b0;
    else if (count == BPS_CNT) //循环一圈，表示发送了一个数据
       bps_clk <= 1'b1;   //时钟抬高，置1
    else 
       bps_clk <= 1'b0;   
end

// function integer log2(input integer v);
//   begin
// 	log2=0;
// 	while(v>>log2) 
// 	  log2=log2+1;
//   end
// endfunction

endmodule