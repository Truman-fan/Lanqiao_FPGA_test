`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/02 13:40:36
// Design Name: 
// Module Name: TOP
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


module TOP(
    input   wire    clk,
    input   wire    rst,
    
    input   wire    [3:0]   Key,    //按键，低有效
    
    output  wire    LED,            //LED，低有效
    
    output  wire    [7:0]   seg,
    output  wire    [7:0]   sel,    //数码管
    
    output	wire	tx      //串口(发送端)
    );
  
  
 
  
  //-------------------------------- 按键消抖部分 ---------------------------------//
  wire  [3:0] Key_out;  //消抖后的按键信号
 
  key_debounce #(.DELAY_CNT('d1_000_000))//50M时钟的计数值
    u_key_debounce_0(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[0]    ), 
    .key_out(Key_out[0]) 
    );
  
  key_debounce #(.DELAY_CNT('d1_000_000))//50M时钟的计数值
    u_key_debounce_1(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[1]    ), 
    .key_out(Key_out[1]) 
    );
    
  key_debounce #(.DELAY_CNT('d1_000_000))//50M时钟的计数值
    u_key_debounce_2(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[2]    ), 
    .key_out(Key_out[2]) 
    );

  key_debounce #(.DELAY_CNT('d1_000_000))//50M时钟的计数值
    u_key_debounce_3(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[3]    ), 
    .key_out(Key_out[3]) 
    ); 
  
  
  
  //-------------------------------- 计数器电路及控制部分 ---------------------------------//
  
  wire  [9:0]   count;
  
  counter count_ctrl(
    .clk            (clk),
    .rst            (rst),
    .Key            (Key_out[2:0]), // 消抖后的 S1-S3 按键信号
    .LED            (LED),          //  表示计数器状态： 启动/暂停
    .count          (count) 
    );
  
  
  /////////////////////////  数码管 和 串口 显示计数器数值 部分
  wire [3:0]    count_0;        //计数器个位
  wire [3:0]    count_1;        //计数器十位
  wire [3:0]    count_2_temp;           //计数器百位，但不直接送入数码管显示
  wire          count_2_equ_zero;       //计数器百位是否为0的判断
  wire [3:0]    count_2;                //送入数码管显示的计数器百位，
                    //为0时显示大于9且非“C”的值，这里用的是“A”，在数码管控制里为熄灭效果。
  assign count_0 = count % 10;
  assign count_1 = (count / 10) % 10;
  assign count_2_temp = (count / 100) % 10;
  assign count_2_equ_zero = (count_2_temp==4'h0);
  assign count_2 = count_2_equ_zero ? 4'hA : count_2_temp;
  
  wire  [31:0]  seg_number_in;      // 数码管显示数据
  assign seg_number_in = {20'hC_AAAA, count_2, count_1, count_0};
  
  
  //-------------------------------- 数码管控制部分 ---------------------------------//
  
  //C:12; 空：10；
  seg segdisplay
    (
	   .clk                (clk),
	   .rst                (rst),	
	   .seg_number_in      (seg_number_in),
	   .seg_number         (seg),  //段码
	   .seg_choice         (sel)//位码
    );
  
  
  //-------------------------------- 串口控制部分 ---------------------------------//
  uart_char_tx uart(            // 题目要求仅发送，故没有rx接收端口
        .clk                (clk),        
        .rst                (rst),        
        .count_0            (count_0),
        .count_1            (count_1),
        .count_2            (count_2),
        .count_2_equ_zero   (count_2_equ_zero),
        .start              (!Key_out[3]),      //用于发送计数器数据的消抖按键信号S4
        .tx                 (tx)
    );
  
  
  
endmodule
