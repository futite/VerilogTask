`include "define.sv"
module UART_tx
// #(
//     parameter CLK_FREQUENCE = 50_000_000  ,
//               BAUD_RATE      = 9600        ,
//               PARITY         = "NONE"      ,
//               FRAME_WD       = 8
// )
(   
    input logic  clk       ,
    input logic  rst_n     ,
    input logic  frame_en  ,
    input logic  [`FRAME_WD-1:0] data_frame ,
    output logic tx_done,
    output logic uart_tx
);
logic bps_clk;
logic [1:0] verify_mode;
logic [`FRAME_WD-1: 0]      data_reg  ;
logic [$clog2(`FRAME_WD-1)-1:0]    cnt  ;
logic                    parity_bit  ;

tx_clk_gen
// #(
// 	.CLK_FREQUENCE	(`CLK_FREQUENCE),		//hz
// 	.BAUD_RATE		(`BAUD_RATE	)	 		//9600、19200 、38400 、57600 、115200、230400、460800、921600
// )
tx_clk_gen_inst
(
	.clk			( clk		 ),		//system_clk
	.rst_n			( rst_n		 ),		//system_reset
	.tx_done		( tx_done	 ),		//once_tx_done
	.tx_start		( frame_en	 ),		//once_tx_start
	.bps_clk		( bps_clk	 ) 		//baud_rate_clk
);

generate
    if (`PARITY == "ODD")
      assign verify_mode = 2'b01 ;
    else if (`PARITY == "EVEN")
      assign verify_mode = 2'b10 ;
    else
      assign verify_mode = 2'b00 ;
endgenerate


typedef enum logic [5:0] {
         IDLE		,
         READY  	,
         START_BIT	,
         SHIFT_PRO	,
         PARITY_BIT	,
         STOP_BIT   ,
         DONE       	        
    } state_t;
    state_t c_state, n_state;

//计数判断
always_ff @( posedge clk or negedge rst_n ) begin
    if (!rst_n)
    cnt <= 'd0; //{log2(FRAME_WD){1'b0}};//或者 ’d0
    else if (c_state == SHIFT_PRO & bps_clk ==1'b1)//处于发送状态
        if (cnt == `FRAME_WD-1)//发送完成
            cnt <= 'd0;
        else 
            cnt <= cnt + 1'b1;
    else 
        cnt <= cnt;
end

//FSM-1 状态转移
always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n)
       c_state <= IDLE;
    else 
       c_state <= n_state;
end

//FSM-2 具体的状态转移
always_comb begin 
    case (c_state)
         IDLE      : n_state = frame_en ? READY : IDLE ;
         READY     : n_state = (bps_clk == 1'b1) ? START_BIT : READY ;
         START_BIT : n_state = (bps_clk == 1'b1) ? SHIFT_PRO : START_BIT ;
         SHIFT_PRO : n_state = (cnt == `FRAME_WD-1 & bps_clk ==1'b1) ? PARITY_BIT : SHIFT_PRO;
         PARITY_BIT: n_state = (bps_clk == 1'b1) ? STOP_BIT : PARITY_BIT;
         STOP_BIT  : n_state = (bps_clk == 1'b1) ? DONE : STOP_BIT;
         DONE      : n_state = IDLE;
         default   : n_state = IDLE;    
    endcase   
end

//FSM-3 数据处理
always_ff @( posedge clk or negedge rst_n ) begin 
    if ( !rst_n) begin
    data_reg <= 'd0;
    uart_tx <= 1'b1;
    tx_done <= 1'b0;
    parity_bit <= 1'b0;
    end else begin
        case (n_state)
            IDLE      : begin
                        data_reg <= 'd0;
                        uart_tx <= 1'b1;
                        tx_done <= 1'b0;
                       end
            READY     : begin
                        data_reg <= 'd0;
                        uart_tx <= 1'b1;
                        tx_done <= 1'b0;
                       end
            START_BIT : begin
                        data_reg <= data_frame;
                        parity_bit <= ^data_frame;
                        uart_tx <= 1'b0;//0为起始位
                        tx_done <= 1'b0;
                        end
            SHIFT_PRO : begin
                          if (bps_clk == 1'b1) begin
                              data_reg <= {1'b0,data_reg[`FRAME_WD-1:1]};
                              uart_tx  <= data_reg[0];
                              end 
                         else begin
                              data_reg <= data_reg;
                              uart_tx  <= uart_tx;
                              end
                        tx_done <= 1'b0;
                        end
            PARITY_BIT: begin
                          data_reg <= data_reg;
                          tx_done  <= 1'b0;
                          case (verify_mode)
                                2'b00: uart_tx <= 1'b1;
                                2'b01: uart_tx <= ~parity_bit; //偶校验，1数量为偶数，则校验码为0
                                2'b10: uart_tx <= parity_bit; 
                                default: uart_tx <= 1'b1;
                          endcase
                        end
            STOP_BIT  : uart_tx <= 1'b1;//波形图最后一位位1
            DONE      : tx_done <= 1'b1;
            default   : begin
                         data_reg <= 'd0;
                         uart_tx <= 1'b1;
                         tx_done <= 1'b0;
                         parity_bit <= 1'b0;
                        end
        endcase
    end
end





endmodule