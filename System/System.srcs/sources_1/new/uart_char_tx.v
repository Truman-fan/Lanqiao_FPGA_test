`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/02 15:06:33
// Design Name: 
// Module Name: uart_char_tx
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


module uart_char_tx(
    input          clk,        
    input          rst,        
    input  [3:0]   count_0,      // ��7���ַ�
    input  [3:0]   count_1,      // ��8���ַ�
    input  [3:0]   count_2,      // ��9���ַ�
    input          count_2_equ_zero,
    input          start,      // ������������
    output         tx          // �����������
);

//  C O U N T : X X X
//43 4F 55 4E 54 3A 
// ========== ״̬�����ź����� ==========
reg [3:0] state;               // ��״̬��
reg [3:0] char_index;           // �ַ�������0~8��
wire      tx_data_vld;          // �ַ�����ʹ��
reg [7:0] tx_data;              // ��ǰ�����ַ�
wire      ready;                // ����ģ�������־

// ״̬����
localparam IDLE   = 4'd0;       // ����״̬
localparam SEND   = 4'd1;       // ����״̬

// ========== ���ڷ���ģ��ʵ���� ==========
uart_tx uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .tx_data_vld(tx_data_vld),
    .ready(ready),
    .tx(tx)
);

// ========== ����ѡ�����߼� ==========��
always @(*) begin
    case (char_index)
        4'd1:  tx_data = 8'h43;
        4'd2:  tx_data = 8'h4F;
        4'd3:  tx_data = 8'h55;
        4'd4:  tx_data = 8'h4E;
        4'd5:  tx_data = 8'h54;
        4'd6:  tx_data = 8'h3A;
        4'd7:  tx_data = count_2_equ_zero ? (count_1+8'h30): (count_2+8'h30);
        4'd8:  tx_data = count_2_equ_zero ? (count_0+8'h30): (count_1+8'h30);
        4'd9:  tx_data = (count_0+8'h30);
        default: tx_data = 8'h00;
    endcase
end
//0x43 4F 55 4E 54 3A ��Ϊ ��COUNT:����ASCII��
//0-9�����ַ���ASII��Ϊ0x30 - 0x39 


wire    [3:0]   state_send_char;
assign state_send_char = count_2_equ_zero ? 4'd8 : 4'd9;

// ========== ����״̬�� ==========
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        char_index <= 4'd0;     // ��ʼ��Ϊ��Ч����
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= SEND;
                    char_index <= 4'd1;  // �ӵ�1���ַ���ʼ
                end
            end
            
            SEND: begin
                if (ready && (char_index < state_send_char)) begin
                    char_index <= char_index + 1;  // �л�����һ�ַ�
                end else if (ready && (char_index == state_send_char)) begin
                    state <= IDLE;       // ������ɣ����ؿ���
                    char_index <= 4'd0;  // ��������
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end

// ========== ����ʹ������ ==========
assign tx_data_vld = (state == SEND) && ready;

endmodule
