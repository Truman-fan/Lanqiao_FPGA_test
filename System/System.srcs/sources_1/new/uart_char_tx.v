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
    input  [3:0]   count_0,      // 第7个字符
    input  [3:0]   count_1,      // 第8个字符
    input  [3:0]   count_2,      // 第9个字符
    input          count_2_equ_zero,
    input          start,      // 启动发送脉冲
    output         tx          // 串行输出引脚
);

//  C O U N T : X X X
//43 4F 55 4E 54 3A 
// ========== 状态机与信号声明 ==========
reg [3:0] state;               // 主状态机
reg [3:0] char_index;           // 字符索引（0~8）
wire      tx_data_vld;          // 字符发送使能
reg [7:0] tx_data;              // 当前发送字符
wire      ready;                // 串口模块就绪标志

// 状态编码
localparam IDLE   = 4'd0;       // 空闲状态
localparam SEND   = 4'd1;       // 发送状态

// ========== 串口发送模块实例化 ==========
uart_tx uart_tx_inst (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .tx_data_vld(tx_data_vld),
    .ready(ready),
    .tx(tx)
);

// ========== 数据选择器逻辑 ==========，
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
//0x43 4F 55 4E 54 3A 均为 “COUNT:”的ASCII码
//0-9数字字符的ASII码为0x30 - 0x39 


wire    [3:0]   state_send_char;
assign state_send_char = count_2_equ_zero ? 4'd8 : 4'd9;

// ========== 控制状态机 ==========
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        char_index <= 4'd0;     // 初始化为无效索引
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    state <= SEND;
                    char_index <= 4'd1;  // 从第1个字符开始
                end
            end
            
            SEND: begin
                if (ready && (char_index < state_send_char)) begin
                    char_index <= char_index + 1;  // 切换到下一字符
                end else if (ready && (char_index == state_send_char)) begin
                    state <= IDLE;       // 发送完成，返回空闲
                    char_index <= 4'd0;  // 重置索引
                end
            end
            
            default: state <= IDLE;
        endcase
    end
end

// ========== 发送使能生成 ==========
assign tx_data_vld = (state == SEND) && ready;

endmodule
