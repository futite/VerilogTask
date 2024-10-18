`include "define.sv"
//双时钟，双使能
module simple_dual_port_ram (
input logic clka,
input logic clkb,
input logic wen,
//input logic ren, 读端口有地址就能读
input logic [$clog2(`DATA_DEPTH)-1:0] w_addr,
input logic [$clog2(`DATA_DEPTH)-1:0] r_addr,
input logic [`DATA_WIDTH-1:0] w_data ,
output logic [`DATA_WIDTH-1:0] r_data 


);
 logic wen_d1;
 //logic ren_d1;
 logic [$clog2(`DATA_DEPTH)-1:0] w_addr_d1;
 logic [$clog2(`DATA_DEPTH)-1:0] r_addr_d1;
 logic [`DATA_WIDTH-1:0] din_d ;
 logic [`DATA_WIDTH-1:0] last_data;
//  //yes可对同一地址进行读写
//(* rw_addr_collision = "yes" *)`RAM_STYLE_VAL
 (* ram_style = `RAM_STYLE_VAL *) logic [`DATA_WIDTH-1:0]  data_reg [`DATA_DEPTH-1:0] = '{default : '0};


//  logic [ `DATA_WIDTH-1:0] mem  [`DATA_DEPTH-1:0];
//  initial begin
//    $readmemh("D:/VerilogCodeSelf/RAM_DDS/ram_init_random.txt", mem);
//  end



  always_ff @( posedge clka ) begin
    wen_d1    <= wen;
    w_addr_d1 <= w_addr;
    din_d       <= w_data; //信号寄存
  end
  
  always_ff @( posedge clkb ) begin
   // ren_d1    <= ren;
    r_addr_d1 <= r_addr;  //信号寄存
  end

  case (`FIGHT_MODE)
    1 : begin   //读优先
      always_ff @( posedge clka ) begin 
        if(wen_d1) begin
          data_reg[w_addr_d1] <= din_d;        
        end
          
      end   
       always_ff @( posedge clkb ) begin
      //   if(ren_d1) begin
       r_data <= data_reg[r_addr_d1]; 
      //   end        
      end

    end

    2: begin   //写优先
      always_ff @( posedge clka ) begin 
        if (wen_d1) begin
          data_reg[w_addr_d1] <= din_d;
          r_data <= din_d;         
        end
        // else begin
        //   r_data <= data_reg[r_addr_d1];
        // end
      end
      always_ff @( posedge clkb ) begin
       if(!wen_d1)begin
        r_data <= data_reg[r_addr_d1];
       end
      end
    end
    
   
    3: begin  //保持
      always_ff @( posedge clka ) begin 
        if(wen_d1) begin
        data_reg[w_addr_d1] <= din_d ; 
        end 
        // else begin
        //   last_data <= data_reg[r_addr_d1]; 
        // end
      end
      always_ff @( posedge clkb ) begin
        if(!wen_d1)begin
          last_data <= data_reg[r_addr_d1]; 
        end
      end
      assign r_data = wen_d1? last_data : data_reg[r_addr_d1] ;
     end
    
  endcase
  
//   always_ff @( posedge clka) begin 
//       if(wen_d1)
//       data_reg[w_addr_d1] <= din_d;
//   end

//   always_ff @( posedge clkb) begin 
//     if(ren_d1)
//     r_data <= data_reg[r_addr_d1];
// end

endmodule