`include "define.sv"
module rx_clk_gen #(
    parameter SAMP_POINT = 9
    //BAUD_RATE =9600
) (
    input  logic clk,
    input  logic rst_n,
    input  logic rx_start,
    input  logic rx_done,
    output logic sample_clk
);
    localparam SAM_CLK_CNT = `CLK_FREQUENCE / `BAUD_RATE / SAMP_POINT - 1,  //采样时钟计数，细分的小模块，数据确保准确.这个表达式计算了为了实现每个比特9个采样点，每一个采样点所需的时钟计数
    CNT_WIDTH = $clog2(
        SAM_CLK_CNT
    );
    logic [CNT_WIDTH:0] clk_count;  //采样时钟计数器clk_count从0到SMP_CLK_CNT，完成了一个bit的一个采样点采样

    typedef enum logic [1:0] {
        IDLE,
        RECEIVE
    } state_t;
    state_t c_state, n_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) c_state <= IDLE;
        else c_state <= n_state;  //修改之前为Recveive
    end

    always_comb begin
        case (c_state)
            IDLE:    n_state = rx_start ? RECEIVE : IDLE;
            RECEIVE: n_state = rx_done ? IDLE : RECEIVE;
            default: n_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_count <= 1'd0;
        else if (c_state == IDLE) clk_count <= 1'd0;
        else if (clk_count == SAM_CLK_CNT)  //所需的系统时钟数
            clk_count <= 1'd0;
        else clk_count <= clk_count + 1'd1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk <= 1'd0;
        else if (clk_count == SAM_CLK_CNT)  //,修改之前为1'b1;刚开始计数，sample为1，表示采集到一个新的采样点
            sample_clk <= 1'b1;
        else sample_clk <= 1'b0;
    end

endmodule


