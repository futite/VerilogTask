`include "define.sv"

module UART_top_tb;
    
    parameter CLK_PERIOD = 20; // 50MHz clock -> 20ns period
    
    logic clk;
    logic rst_n;
    logic uart_rx;
    logic uart_tx;
    
    initial begin
        clk = 1;
        forever #10 clk = ~clk;
    end

    
    
    UART_top inst (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );
    
    task send_uart_byte(input [7:0] data);
    integer i;
    begin
        uart_rx = 1'b0;
        #(CLK_PERIOD * (`CLK_FREQUENCE/`BAUD_RATE));         
        for (i = 0; i < 8; i = i + 1) begin
            uart_rx = data[i];
            #(CLK_PERIOD * (`CLK_FREQUENCE/`BAUD_RATE)); 
        end
        
      uart_rx = 1'b1;
        #(CLK_PERIOD * (`CLK_FREQUENCE/`BAUD_RATE)); //另一种写法，for循环内为i<10，data宽度为[9:]，则下面发送的数据为10bit包涵起始位与停止位形式为：0xxxxxxxx1
    end
   endtask

//logic a;
    
    initial begin
        rst_n = 1'b0;
        uart_rx = 1'b1;  // Idle state for UART
        
        #100;
        rst_n = 1'b1;
        
        #100;      
        
        send_uart_byte(8'b11101100); 
        //uart_rx = 'b1;//持续拉高
       
        #(400*(`CLK_FREQUENCE/`BAUD_RATE)); // Wait for some cycles for the reception and transmission
        
        
        send_uart_byte(8'b10111010); 
        
        // Finish the simulation
       // a= 1'b1;
       // #100000;
       // $finish;
    end

    
endmodule
