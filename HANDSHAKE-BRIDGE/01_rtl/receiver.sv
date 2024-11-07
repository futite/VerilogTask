`include "define.sv"
module receiver 

(
    input  logic                   clk,
    input  logic [`DATA_WIDTH-1:0] data_receiver,
    input  logic                  read_en='0,
   // input  logic                  receiver_en='0,
    input  logic                  rst_n,
    input  logic                  req,
    //output logic [`DATA_WIDTH-1:0] data_show,
    output logic                  full,
    output logic                  empty,
   // output logic                pro_full,
   // output logic                pro_empty,
    output logic                  ack
    //output logic                 ena,
    //output logic [`DATA_WIDTH-1:0] data_receive,
    //input  logic                out_ready,
    //output logic                ack 
   
);
   
    logic receiver_en=0;
    logic [$clog2(`DATA_DEPTH):0] fifo_cnt;
    logic [      `DATA_WIDTH-1:0] mem     [`DATA_DEPTH-1:0];
    logic [$clog2(`DATA_DEPTH)-1:0] wr_addr;
    logic [$clog2(`DATA_DEPTH)-1:0] rd_addr;
    //logic [`DATA_WIDTH-1:0] data_reg;
    logic valid1='0;

    // always_ff @(posedge clk or negedge rst_n) begin : show_receiver_data
    //     if (!rst_n) begin
    //         rd_addr  <= '0;
    //        // data_out <= '0;
    //     end 
    //     else if(`FIFO_MODE=="Standard") begin
    //         if(!empty) begin  // && receiver_en
    //         // fifo_cnt ='0;
    //              valid1 <=1;
    //              //valid  <=1;
    //         end
    //         if(valid1==1&read_en) begin    
    //         rd_addr <= (rd_addr +1);//%`DATA_DEPTH;
    //         data_show    <= mem[rd_addr];
    //         valid1=(!(rd_addr==`DATA_DEPTH));
    //        // data_out<=data_reg;
    //         end
    //     end  
    // end

    always_ff @( posedge  clk or negedge rst_n) begin 
        if (!rst_n) begin
           ack<=0;
        end 
        //else ack<=req;
        receiver_en<=req&ack;
           
    end
    assign read_en=req&ack;
    //assign 
    always_ff @(posedge clk or negedge rst_n) begin : write_from_Bridge
        if (!rst_n) begin
            wr_addr <= '0;
        end else if (!full&read_en) begin //&& 
            wr_addr <= wr_addr+1;//%`DATA_DEPTH;
            mem[wr_addr] <= data_receiver;
        end else mem[wr_addr] <= mem[wr_addr];
    end

    always_ff @(posedge clk or negedge rst_n) begin : cnt
        if (!rst_n) begin
            fifo_cnt <= '0;
        end else begin
            case ({read_en, receiver_en})
                2'b01:
                if (fifo_cnt != 0) begin
                    fifo_cnt <= fifo_cnt - 1;
                end
                2'b10:
                if (fifo_cnt != `DATA_DEPTH) begin
                    fifo_cnt <= fifo_cnt + 1;
                end
                default: fifo_cnt <= fifo_cnt;
            endcase
        end
    end
 assign empty = (!fifo_cnt);
 assign full  = (fifo_cnt== `DATA_DEPTH);
 always_ff @( posedge clk  ) begin
    if(!req) ack<='0;
    
 end

//  assign pro_empty =(fifo_cnt!=0&&fifo_cnt<`empty_max);
//  assign pro_full  =(fifo_cnt>`full_min);  //控制范围，实现水位配置。
//     // always_comb begin
    //     if (fifo_cnt == 0) begin
    //         empty = 1;
    //     end
    //     if (fifo_cnt == `DATA_DEPTH) begin
    //         full = 1;
    //     end
    // end
endmodule
