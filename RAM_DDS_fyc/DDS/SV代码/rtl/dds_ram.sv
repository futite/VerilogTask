`include "define.sv"
module dds_ram (
input logic clk ,
//input logic rst_n,
input logic wea,
input logic [$clog2(`DATA_DEPTH)-1:0] addr,
input logic [`DATA_WIDTH-1:0] wr_data ,
output logic [`DATA_WIDTH-1:0] re_data 
);

(* RAM_STYLE = `RAM_STYLE_VAL *)logic [`DATA_WIDTH-1:0]  data_reg [`DATA_DEPTH-1:0] = '{default : '0};

// logic we_d1;
// logic [$clog2(`DATA_DEPTH)-1:0]  addr_d1;
// logic [`DATA_WIDTH-1:0] din_d1;

// always_ff @( posedge clk ) begin 
// we_d1 <= wea;
// addr_d1 <= addr;
// din_d1 <= wr_data;   //信号寄存一个周期
// end

//logic [ `DATA_WIDTH-1:0] mem     [`DATA_DEPTH-1:0];
initial begin
    $readmemb("D:/VerilogCodeSelf/RAM_DDS/DDS/dds_data_init.txt", data_reg);
end

case (`FIGHT_MODE)
   1 : begin  //读优先
    always_ff @( posedge clk ) begin 
        if(wea) begin
            data_reg[addr] <= wr_data;
        end
        re_data <= data_reg[addr];    //这句必定执行    
    end
   end

   2 : begin
    always_ff @( posedge clk ) begin //写优先
        if(wea) begin
            data_reg[addr] <= wr_data;
            re_data <= wr_data;
        end
        else begin
            re_data <= data_reg[addr];
        end        
    end
   end

   3 : begin
    always_ff @( posedge clk ) begin //保持
        if(wea) begin
            data_reg[addr] <= wr_data;
        end
        else begin
            re_data <= data_reg[addr]; //if不满足时才执行
        end        
    end
   end
endcase

// initial begin
// $readmemh("D:/VerilogCodeSelf/RAM_DDS/ram_init_random.txt", mem);
// end


endmodule