`include "define.sv"
module sender 

(
    input  logic                   clk,
    input  logic [`DATA_WIDTH-1:0] data_in,
    input  logic                  wr_en='0,
    input  logic                  send_en='0,
    input  logic                  rst_n,
    input  logic                  ready,
    output logic [`DATA_WIDTH-1:0] data_send,
    output logic                  full,
    output logic                  empty,
   // output logic                pro_full,
   // output logic                pro_empty,
    output logic                  valid
    //output logic                 ena,
    //output logic [`DATA_WIDTH-1:0] data_receive,
    //input  logic                out_ready,
    //output logic                ack 
   
);
   
  
    logic [$clog2(`DATA_DEPTH):0] fifo_cnt;
    logic [      `DATA_WIDTH-1:0] mem     [`DATA_DEPTH-1:0];
    logic [$clog2(`DATA_DEPTH)-1:0] wr_addr;
    logic [$clog2(`DATA_DEPTH)-1:0] rd_addr;
    logic [`DATA_WIDTH-1:0] data_reg;
    logic valid1;

    always_ff @(posedge clk or negedge rst_n) begin : read
        if (!rst_n) begin
            rd_addr  <= '0;
           // data_out <= '0;
        end 
        else if(`FIFO_MODE=="FWFT") begin
            if(!empty && send_en&ready) begin
           // fifo_cnt ='0;
               rd_addr <= (rd_addr +1);//%`DATA_DEPTH;         
            end 
            else begin rd_addr <= rd_addr; end
            data_send <= mem[rd_addr];               
        end 
        else if(`FIFO_MODE=="Standard") begin
            if(!empty && send_en) begin
            // fifo_cnt ='0;
                 valid1 <=1;
                 //valid  <=1;
            end
            valid<=!empty;//非空，说明有数据可以读
            if(valid1==1&&ready==1) begin    //数据输出到Bridge
            rd_addr <= (rd_addr +1);//%`DATA_DEPTH;
            data_send    <= mem[rd_addr];
            valid1=(!(rd_addr==`DATA_DEPTH));
           // data_out<=data_reg;
            end
        end
       
    end


    always_ff @(posedge clk or negedge rst_n) begin : write
        if (!rst_n) begin
            wr_addr <= '0;
        end else if (!full && wr_en) begin
            wr_addr <= wr_addr+1;//%`DATA_DEPTH;
            mem[wr_addr] <= data_in;
        end else mem[wr_addr] <= mem[wr_addr];
    end

    always_ff @(posedge clk or negedge rst_n) begin : cnt
        if (!rst_n) begin
            fifo_cnt <= '0;
        end else begin
            case ({wr_en, send_en})
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
