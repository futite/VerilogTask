`include "define.sv"
module true_dual_port_ram(
    input logic clka,
    input logic wea,
    input logic [$clog2(`DATA_DEPTH)-1:0] addra,
    input logic [`DATA_WIDTH-1:0] dina ,
    output logic [`DATA_WIDTH-1:0] douta,

    input logic clkb,
    input logic web, 
    input logic [$clog2(`DATA_DEPTH)-1:0] addrb,
    input logic [`DATA_WIDTH-1:0] dinb ,
    output logic [`DATA_WIDTH-1:0] doutb
);
 logic wea_d1;
 logic web_d1;
 logic [$clog2(`DATA_DEPTH)-1:0] addra_d1;
 logic [$clog2(`DATA_DEPTH)-1:0] addrb_d1;
 logic [`DATA_WIDTH-1:0] dina_d1 ;
 logic [`DATA_WIDTH-1:0] dinb_d1 ;
 logic [`DATA_WIDTH-1:0] last_data;

(* ram_style = `RAM_STYLE_VAL *) logic [`DATA_WIDTH-1:0]  data_reg [`DATA_DEPTH-1:0] = '{default : '0};
always_ff @( posedge clka ) begin 
    wea_d1   <= wea;
    addra_d1 <= addra;
    dina_d1 <=  dina;
end

always_ff @( posedge clkb ) begin 
    web_d1   <= web;
    addrb_d1 <= addrb;
    dinb_d1 <=  dinb;
end


always_ff @( posedge clka ) begin 
    case(`A_PORT_FIGHT_MODE)
        1 : begin //读优先
            if(wea_d1)begin
                data_reg[addra_d1] <= dina_d1;
            end
            douta <= data_reg[addra_d1];  
        end

        2 : begin //写优先
            if(wea_d1)begin
                data_reg[addra_d1] <= dina_d1;
                douta <= dina_d1;
            end
            else begin
                douta <= data_reg[addra_d1];
            end
        end

        3 : begin //保持模式
            if(wea_d1)begin
                data_reg[addra_d1] <= dina_d1;
            end
            else begin
                douta <= data_reg[addra_d1]; 
            end    
        end
    endcase  
end

always_ff @( posedge clkb ) begin 
    case(`B_PORT_FIGHT_MODE)
        1 : begin //读优先
            if(web_d1)begin
                data_reg[addrb_d1] <= dinb_d1;
            end
            doutb <= data_reg[addrb_d1];  
        end

        2 : begin //写优先
            if(web_d1)begin
                data_reg[addrb_d1] <= dinb_d1;
                doutb <= dinb_d1;
            end
            else begin
                doutb <= data_reg[addrb_d1];
            end
        end

        3 : begin //保持模式
            if(web_d1)begin
                data_reg[addrb_d1] <= dinb_d1;
            end
            else begin
                doutb <= data_reg[addrb_d1]; 
            end    
        end
    endcase  
end




endmodule