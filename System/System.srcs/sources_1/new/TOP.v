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
    
    input   wire    [3:0]   Key,    //����������Ч
    
    output  wire    LED,            //LED������Ч
    
    output  wire    [7:0]   seg,
    output  wire    [7:0]   sel,    //�����
    
    output	wire	tx      //����(���Ͷ�)
    );
  
  
 
  
  //-------------------------------- ������������ ---------------------------------//
  wire  [3:0] Key_out;  //������İ����ź�
 
  key_debounce #(.DELAY_CNT('d1_000_000))//50Mʱ�ӵļ���ֵ
    u_key_debounce_0(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[0]    ), 
    .key_out(Key_out[0]) 
    );
  
  key_debounce #(.DELAY_CNT('d1_000_000))//50Mʱ�ӵļ���ֵ
    u_key_debounce_1(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[1]    ), 
    .key_out(Key_out[1]) 
    );
    
  key_debounce #(.DELAY_CNT('d1_000_000))//50Mʱ�ӵļ���ֵ
    u_key_debounce_2(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[2]    ), 
    .key_out(Key_out[2]) 
    );

  key_debounce #(.DELAY_CNT('d1_000_000))//50Mʱ�ӵļ���ֵ
    u_key_debounce_3(
    .clk    (clk    ), 
    .rst    (rst    ),
    .key    (Key[3]    ), 
    .key_out(Key_out[3]) 
    ); 
  
  
  
  //-------------------------------- ��������·�����Ʋ��� ---------------------------------//
  
  wire  [9:0]   count;
  
  counter count_ctrl(
    .clk            (clk),
    .rst            (rst),
    .Key            (Key_out[2:0]), // ������� S1-S3 �����ź�
    .LED            (LED),          //  ��ʾ������״̬�� ����/��ͣ
    .count          (count) 
    );
  
  
  /////////////////////////  ����� �� ���� ��ʾ��������ֵ ����
  wire [3:0]    count_0;        //��������λ
  wire [3:0]    count_1;        //������ʮλ
  wire [3:0]    count_2_temp;           //��������λ������ֱ�������������ʾ
  wire          count_2_equ_zero;       //��������λ�Ƿ�Ϊ0���ж�
  wire [3:0]    count_2;                //�����������ʾ�ļ�������λ��
                    //Ϊ0ʱ��ʾ����9�ҷǡ�C����ֵ�������õ��ǡ�A����������ܿ�����ΪϨ��Ч����
  assign count_0 = count % 10;
  assign count_1 = (count / 10) % 10;
  assign count_2_temp = (count / 100) % 10;
  assign count_2_equ_zero = (count_2_temp==4'h0);
  assign count_2 = count_2_equ_zero ? 4'hA : count_2_temp;
  
  wire  [31:0]  seg_number_in;      // �������ʾ����
  assign seg_number_in = {20'hC_AAAA, count_2, count_1, count_0};
  
  
  //-------------------------------- ����ܿ��Ʋ��� ---------------------------------//
  
  //C:12; �գ�10��
  seg segdisplay
    (
	   .clk                (clk),
	   .rst                (rst),	
	   .seg_number_in      (seg_number_in),
	   .seg_number         (seg),  //����
	   .seg_choice         (sel)//λ��
    );
  
  
  //-------------------------------- ���ڿ��Ʋ��� ---------------------------------//
  uart_char_tx uart(            // ��ĿҪ������ͣ���û��rx���ն˿�
        .clk                (clk),        
        .rst                (rst),        
        .count_0            (count_0),
        .count_1            (count_1),
        .count_2            (count_2),
        .count_2_equ_zero   (count_2_equ_zero),
        .start              (!Key_out[3]),      //���ڷ��ͼ��������ݵ����������ź�S4
        .tx                 (tx)
    );
  
  
  
endmodule
