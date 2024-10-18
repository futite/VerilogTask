`include "define.sv"
module UART_top (
    input  logic clk,
    input  logic rst_n,
    input  logic uart_rx,
    output logic uart_tx
);
    logic [`FRAME_WD-1:0] rx_frame;
    logic                 frame_en;
    logic                 tx_done;
    logic                 rx_done;
    logic [`FRAME_WD-1:0] dout;
    logic                 frame_error;

    UART_tx UART_tx_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .frame_en  (frame_en),
        .data_frame(dout),
        .tx_done   (tx_done),
        .uart_tx   (uart_tx)
    );

    UART_rx UART_rx_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .uart_rx    (uart_rx),
        .rx_frame   (rx_frame),    //[7:0]
        .rx_done    (rx_done),
        .frame_error(frame_error)
    );

    logic wr_en;
    logic rd_en;
    //logic rd_clk;
    // always_ff @( negedge clk or negedge rst_n ) begin //rx数据结果写入FIFO
    //     if(!full&rx_done) begin
    // 		wr_en = 'b1;		
    // 	end
    // 	else wr_en = '0;	
    // end
    assign wr_en    = !full & rx_done;
    assign rd_en    = wr_ack & !empty;
    assign frame_en = rd_en;  //采用assign语句，保证信号实时变化，从而是FIFO读取信息时，能及时读取到
    // always_ff @( posedge clk or negedge rst_n ) begin
    // 	if(wr_ack&!empty) begin
    // 	   rd_en = 'b1 ;
    // 	end
    // 	else rd_en = '0;
    // end


    // always_ff @( posedge clk or negedge rst_n ) begin 
    // 	if(rd_en)
    // 	   frame_en = 1'b1;
    // 	else 
    // 		frame_en = '0;
    // end




    fifo_generator_0 fifo_inst (
        .clk   (clk),       // input wire clk
        .srst  (!rst_n),    // input wire srst
        .din   (rx_frame),  // input wire [7 : 0] din
        .wr_en (wr_en),     // input wire wr_en
        .rd_en (rd_en),     // input wire rd_en
        .dout  (dout),      // output wire [7 : 0] dout
        .full  (full),      // output wire full
        .wr_ack(wr_ack),    // output wire wr_ack
        .empty (empty)      // output wire empty
        //   .valid(valid)    // output wire valid
    );
endmodule
