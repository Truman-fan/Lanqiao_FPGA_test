`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/03 14:53:23
// Design Name: 
// Module Name: key_debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module key_debounce 
#(parameter DELAY_CNT = 'd1_000_000)//50M时钟时的20ms计数值
(    //防抖模块端口声明
      input clk      ,//50M
      input rst      ,
      input key      ,//定义按键输入
      
      output key_out//定义按键输出
);
reg         key_value ;//用于反馈key的值
reg        key_flag ;//按键标志
reg  [$clog2(DELAY_CNT) - 1:0]  delay_cnt ;//用于延时计数
reg                             key_reg  ;//用于记住上一刻key的值

assign key_out = ~(key_flag & ~key_value);

always @ (posedge clk or posedge rst) begin
      if (rst) begin //复位，key_reg置1，即未按下，延时计数清0
            key_reg <= 1'b1;
            delay_cnt <= 'd0;
      end
      else begin
            key_reg <= key; //key_reg记下此时key的值
            if (key_reg != key)  //若按键不稳定
                  delay_cnt <= DELAY_CNT;  //延时计数置满
            else if (key_reg == key) begin
                  if (delay_cnt > 0)
                        delay_cnt <= delay_cnt - 1'd1; 
                        //若20ms延时没结束，每次延时计数减1
                 else
                        delay_cnt <= delay_cnt;
            end
      end   
end                  
             
always @ (posedge clk or posedge rst) begin
      if (rst) begin
            key_flag <= 1'b0;       //复位时按键标志置0
            key_value <= 1'b1;    //按键值置1
      end
      else begin
            if (delay_cnt == 'd1) begin 
                  //20ms延时结束，按键标志置1，反馈值记下此时key的值
                  key_flag <= 1'b1;
                  key_value <= key;
           end
            else begin //20ms延时未到按键标志置0
                  key_flag <= 1'b0;
                  key_value <= key_value;
             end
        end
 end

endmodule
