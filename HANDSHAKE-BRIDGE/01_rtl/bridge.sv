`include "define.sv"
module bridge(
    input logic clk,
    input logic reset, 
    input logic valid,  //Sender发到bridge的有效信号
    output logic ready, //bridge返回给bridge的准备信号
    output logic req,  //bridge发送给receiver的请求信号
    input logic ack,//Receiver返回给bridge的确认信号
    input logic [`DATA_WIDTH-1:0] data_in,
    output logic [`DATA_WIDTH-1:0] data_receiver

);
typedef enum logic [2:0]{
    IDLE,
    //WAIT_READY,
    //REQUEST,
    WAIT_ACK,
    RELEASE_REQ
} state_t;
state_t state, next_state;
// always_comb begin    // 状态转移逻辑
//     case (state)
//     IDLE        : next_state = valid? WAIT_READY:IDLE;
//     WAIT_READY  : next_state = ready? WAIT_ACK : WAIT_READY;
//     //REQUEST     : next_state = WAIT_ACK;
//     WAIT_ACK    : next_state = ack? RELEASE_REQ : WAIT_ACK;
//     RELEASE_REQ : next_state = ack? RELEASE_REQ : IDLE;
//     default     : next_state = IDLE;
//     endcase  
// end
logic wr_en;
logic rd_en=0;
assign wr_en=valid&ready;
always_comb begin    // 状态转移逻辑
    case (state)
    IDLE        : next_state = ~empty? WAIT_ACK:IDLE;
    //WAIT_READY  : next_state = ready? WAIT_ACK : WAIT_READY;
    //REQUEST     : next_state = WAIT_ACK;
    WAIT_ACK    : next_state = ack? RELEASE_REQ : WAIT_ACK;
    RELEASE_REQ : next_state = ack? RELEASE_REQ : IDLE;
    default     : next_state = IDLE;
    endcase  
end


always_ff @( posedge clk or negedge reset ) begin  //状态翻转
    if(!reset) state <= IDLE;
    else
        state <= next_state;
end

always_ff @( posedge clk or negedge reset ) begin  
    if(!reset) begin
       ready <= 0;
       req   <= 0;
    end
    else case (state)
        IDLE        : rd_en=0;
       // REQUEST     : 
        WAIT_ACK    : req <= 1;//data_out <= ack? data_in : data_out;
        RELEASE_REQ : begin req <= 0;
                      rd_en=(~req)&(ack);
        end         
        default     : req <= req;
    endcase  
end

 always_ff @( posedge clk  ) begin
        



     
 end



//assign rd_en=(next_state==RELEASE_REQ);//req&ack;
//assign rd_en=req&ack;
sync_fifo inst(
.clk(clk),
.data_in(data_in),
.wr_en(wr_en),
.rd_en(rd_en),
.rst_n(reset),
.data_out(data_receiver),
.full(full),
.empty(empty)
);




endmodule