`include "define.sv"
 module UART_rx //#(
//     parameter CLK_FREQUENCE = 50_000_000,
//               BAUD_RATE     = 9600,
//               PARITY        = "NONE",
//               FRAME_WD      = 8
// ) 
 (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                uart_rx,//接受的信号
    output logic [`FRAME_WD-1:0] rx_frame,
    output logic                rx_done,
    output logic                frame_error
);
    logic                        sample_clk;
    logic                        frame_en;
    logic                        cnt_en;
    logic [                 3:0] sample_clk_cnt;//固定9个采样点，无需参数化
    logic [$clog2(`FRAME_WD+1)-1:0] sample_bit_cnt;
    logic                        baud_rate_clk;
    logic [                 1:0] verify_mode;

    generate
        if (`PARITY == "ODD") assign verify_mode = 2'b01;
        else if (`PARITY == "EVEN") assign verify_mode = 2'b10;
        else assign verify_mode = 2'b00;
    endgenerate

    typedef enum logic [4:0] {
        IDLE,
        START_BIT,
        DATA_FRAME,
        PARITY_BIT,
        STOP_BIT,
        DONE
    } state_t;
    state_t c_state, n_state;

    logic uart_rx0, uart_rx1, uart_rx2, uart_rx3;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx0 <= 1'b0;
            uart_rx1 <= 1'b0;
            uart_rx2 <= 1'b0;
            uart_rx3 <= 1'b0;
        end else begin
            uart_rx0 <= uart_rx;
            uart_rx1 <= uart_rx0;
            uart_rx2 <= uart_rx1;
            uart_rx3 <= uart_rx2;
        end
    end
    assign frame_en = uart_rx3 & uart_rx2 & ~uart_rx1 & ~uart_rx0;  //前后数据有变化，传输开始

    always_ff @(posedge clk or negedge rst_n) begin  //判断是否开始计数
        if (!rst_n) cnt_en <= 1'b0;
        else if (frame_en) cnt_en <= 1'b1;  //数据使能开始时，计数开始
        else if (rx_done) cnt_en <= 1'b0;
        else cnt_en <= cnt_en;
    end

    assign baud_rate_clk = sample_clk & sample_clk_cnt == 4'd8;  //采样9次进行一次波特率时钟计数

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk_cnt <= 4'd0;
        else if (cnt_en) begin
            if (baud_rate_clk)  //波特率周期结束 采集了1bit数据的9次
                sample_clk_cnt <= 4'd0;  //1bit数据传输完之后，采样时钟继续计数
            else if (sample_clk)  //1次采集完成
                sample_clk_cnt <= sample_clk_cnt + 1'b1;
            else sample_clk_cnt <= sample_clk_cnt;
        end else sample_clk_cnt <= 4'd0;
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_bit_cnt <= 'd0;
        else if (c_state == IDLE) sample_bit_cnt <= 'd0;
        else if (baud_rate_clk) sample_bit_cnt <= sample_bit_cnt + 1'b1;  //统计采样到的bit数，比特数到8
        else sample_bit_cnt <= sample_bit_cnt;
    end
    logic [1:0] sample_result;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_result <= 1'b0;
        else if (sample_clk) begin  //在采集过程中，采集到了数据
            case (sample_clk_cnt)
                4'd0:             sample_result <= 2'd0;  //0表示采样的第一个周期,
                4'd3, 4'd4, 4'd5: sample_result <= sample_result + uart_rx;
                default:          sample_result <= sample_result;
            endcase
        end

    end

    //FSM-1
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) c_state <= IDLE;
        else c_state <= n_state;
    end

    //FSM-2 状态判断
    always_comb begin
        n_state = c_state;
        case (c_state)
            IDLE:       n_state = frame_en ? START_BIT : IDLE;
            START_BIT:  n_state = (baud_rate_clk & sample_result[1] == 1'b0) ? DATA_FRAME : START_BIT;
            DATA_FRAME: begin
                case (verify_mode[1] ^ verify_mode[0])
                    1'b1:    n_state = (sample_bit_cnt == (`FRAME_WD) & baud_rate_clk) ? PARITY_BIT : DATA_FRAME;
                    //奇校验或者偶校验，完成8次采样，则n_state进入到效验模式，否则继续在数据传输状态
                    1'b0:    n_state = (sample_bit_cnt == (`FRAME_WD) & baud_rate_clk) ? STOP_BIT : DATA_FRAME;
                    default: n_state = (sample_bit_cnt == (`FRAME_WD)& baud_rate_clk) ? STOP_BIT : DATA_FRAME;
                endcase
            end
            PARITY_BIT: n_state = baud_rate_clk ? STOP_BIT : PARITY_BIT;  //该状态下，baud_rate_clk=1，则采样结束
            STOP_BIT:   n_state = (baud_rate_clk & sample_result[1] == 1'b1) ? DONE : STOP_BIT;
            DONE:       n_state = IDLE;
            default:    n_state = IDLE;
        endcase
    end

    //FSM-3 数据处理
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_frame    <= 'd0;
            rx_done     <= 1'b0;
            frame_error <= 1'b0;
        end else begin
            case (n_state)
                IDLE: begin
                    rx_frame    <= 'd0;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                START_BIT: begin
                    rx_frame    <= 'd0;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                DATA_FRAME: begin
                    if (sample_clk & sample_clk_cnt == 4'd6)  //采样中，前面采样了6次，中间时刻读取数据
                        rx_frame <= {sample_result[1], rx_frame[`FRAME_WD-1:1]};  //结果拼接
                    else rx_frame <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= 1'b0;
                end
                PARITY_BIT: begin
                    rx_frame <= rx_frame;
                    rx_done  <= 1'b0;
                    if (sample_clk_cnt == 4'd8) frame_error <= ^rx_frame ^ sample_result[1];
                    else frame_error <= frame_error;
                end
                STOP_BIT: begin
                    rx_frame    <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= frame_error;
                end
                DONE: begin
                    rx_frame    <= rx_frame;
                    rx_done     <= 1'b1;
                    frame_error <= frame_error;
                end
                default: begin
                    rx_frame    <= rx_frame;
                    rx_done     <= 1'b0;
                    frame_error <= frame_error;
                end
            endcase
        end
    end

    rx_clk_gen 
    // #(
    //     .CLK_FREQUENCE(`CLK_FREQUENCE),
    //     .BAUD_RATE(`BAUD_RATE)
    // ) 
    rx_clk_gen_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx_start  (frame_en),
        .rx_done   (rx_done),
        .sample_clk(sample_clk)
    );

    // function integer log2(input integer v);
    //     begin
    //         log2 = 0;
    //         while (v >> log2) log2 = log2 + 1;
    //     end
    // endfunction

endmodule
