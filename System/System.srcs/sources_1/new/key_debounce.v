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
#(parameter DELAY_CNT = 'd1_000_000)//50Mʱ��ʱ��20ms����ֵ
(    //����ģ��˿�����
      input clk      ,//50M
      input rst      ,
      input key      ,//���尴������
      
      output key_out//���尴�����
);
reg         key_value ;//���ڷ���key��ֵ
reg        key_flag ;//������־
reg  [$clog2(DELAY_CNT) - 1:0]  delay_cnt ;//������ʱ����
reg                             key_reg  ;//���ڼ�ס��һ��key��ֵ

assign key_out = ~(key_flag & ~key_value);

always @ (posedge clk or posedge rst) begin
      if (rst) begin //��λ��key_reg��1����δ���£���ʱ������0
            key_reg <= 1'b1;
            delay_cnt <= 'd0;
      end
      else begin
            key_reg <= key; //key_reg���´�ʱkey��ֵ
            if (key_reg != key)  //���������ȶ�
                  delay_cnt <= DELAY_CNT;  //��ʱ��������
            else if (key_reg == key) begin
                  if (delay_cnt > 0)
                        delay_cnt <= delay_cnt - 1'd1; 
                        //��20ms��ʱû������ÿ����ʱ������1
                 else
                        delay_cnt <= delay_cnt;
            end
      end   
end                  
             
always @ (posedge clk or posedge rst) begin
      if (rst) begin
            key_flag <= 1'b0;       //��λʱ������־��0
            key_value <= 1'b1;    //����ֵ��1
      end
      else begin
            if (delay_cnt == 'd1) begin 
                  //20ms��ʱ������������־��1������ֵ���´�ʱkey��ֵ
                  key_flag <= 1'b1;
                  key_value <= key;
           end
            else begin //20ms��ʱδ��������־��0
                  key_flag <= 1'b0;
                  key_value <= key_value;
             end
        end
 end

endmodule
