`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/02 13:51:33
// Design Name: 
// Module Name: seg
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


module seg
(
	input	wire 			clk							,
	input 	wire 			rst							,	
	input 	wire	[31:0] 	seg_number_in				,
	output 	wire 	[7:0] 	seg_number					,  //段码
	output 	wire 	[7:0] 	seg_choice                     //位码
);
	
localparam 		CNT_WAIT_MAX = 25'd999; 

localparam 		SEG_0 = 8'b1100_0000, SEG_1 = 8'b1111_1001,    // 段码数值部分
				SEG_2 = 8'b1010_0100, SEG_3 = 8'b1011_0000,
				SEG_4 = 8'b1001_1001, SEG_5 = 8'b1001_0010,
				SEG_6 = 8'b1000_0010, SEG_7 = 8'b1111_1000,
				SEG_8 = 8'b1000_0000, SEG_9 = 8'b1001_0000,
				SEG_A = 8'b1000_1000, SEG_B = 8'b1000_0011,
				SEG_C = 8'b1100_0110, SEG_D = 8'b1010_0001,
				SEG_E = 8'b1000_0110, SEG_F = 8'b1000_1110,
				SEG_X = 8'b1011_1111;	//-
localparam 		IDLE  = 8'b1111_1111; 	//OFF

localparam 		SEG_C7 = 8'b0000_0001,                          // 位码位选部分
				SEG_C6 = 8'b0000_0010,
				SEG_C5 = 8'b0000_0100,
				SEG_C4 = 8'b0000_1000,
				SEG_C3 = 8'b0001_0000,
				SEG_C2 = 8'b0010_0000,
				SEG_C1 = 8'b0100_0000,
				SEG_C0 = 8'b1000_0000;

/* */
reg 	[7:0] 	seg_data				;
reg 	[7:0]	seg_a0					;
reg 	[31:0]	cnt_data				;
reg 			cnt						;
reg 	[3:0]	num						;
reg 	[2:0] 	c_status				;				

assign 			seg_number = seg_data	;
assign 			seg_choice = seg_a0		;

//		
always@(posedge clk or posedge rst)	
	if(rst == 1'b1)
		cnt_data <= 1'b0;
	else begin 
		if (cnt_data == CNT_WAIT_MAX-1) begin 
			cnt_data <= 1'b0;
			cnt <= 1;
		end
		else begin 
			cnt_data <= cnt_data + 1;
			cnt <= 0;
		end
	end	
		
wire [3:0] seg_number_in_0 = seg_number_in[3:0]		;			
wire [3:0] seg_number_in_1 = seg_number_in[7:4]		;		
wire [3:0] seg_number_in_2 = seg_number_in[11:8]	;	
wire [3:0] seg_number_in_3 = seg_number_in[15:12]	;	
wire [3:0] seg_number_in_4 = seg_number_in[19:16]	;	
wire [3:0] seg_number_in_5 = seg_number_in[23:20]	;	
wire [3:0] seg_number_in_6 = seg_number_in[27:24]	;	
wire [3:0] seg_number_in_7 = seg_number_in[31:28]	;			
				
//		
always@(posedge clk or posedge rst)
	if(rst == 1'b1)
		begin
			seg_a0 	<= IDLE;
			c_status <= 1'b0;
			num		<= 1'b0;
		end
	else 
		begin 
			if(cnt == 1) begin 
				case(c_status)
					3'd0 :  
						begin 
							num 		<= seg_number_in_0 ;
							seg_a0 	<= ~SEG_C0;
							c_status <= c_status+3'd1;
						end
					3'd1 :  
						begin 
							num 		<= seg_number_in_1 ;
							seg_a0 	<= ~SEG_C1;
							c_status <= c_status+3'd1;
						end
					3'd2 :  
						begin 
							num 		<= seg_number_in_2 ;
							seg_a0 	<= ~SEG_C2;
							c_status <= c_status+3'd1;
						end
					3'd3 :  
						begin 
							num 		<= seg_number_in_3 ;
							seg_a0 	<= ~SEG_C3;
							c_status <= c_status+3'd1;
						end
					3'd4 :  
						begin 
							num 		<= seg_number_in_4 ;
							seg_a0 	<= ~SEG_C4;
							c_status <= c_status+3'd1;
						end
					3'd5 :  
						begin 
							num 		<= seg_number_in_5 ;
							seg_a0 	<= ~SEG_C5;
							c_status <= c_status+3'd1;
						end
					3'd6 :  
						begin 
							num 		<= seg_number_in_6 ;
							seg_a0 	<= ~SEG_C6;
							c_status <= c_status+3'd1;
						end
					3'd7 :  
						begin 
							num 		<= seg_number_in_7 ;
							seg_a0 	<= ~SEG_C7;
							c_status <= c_status+3'd1;
						end
					default :
							c_status <= 3'd0;
				endcase
		
		end
	end

//	
always@(posedge clk or posedge rst)
	if(rst == 1'b1)
		begin
			seg_data <= 8'b1111_1111;
		end
	else case(num)
		4'd0: 		seg_data <= SEG_0;	
		4'd1: 		seg_data <= SEG_1;
		4'd2: 		seg_data <= SEG_2;
		4'd3: 		seg_data <= SEG_3;
		4'd4: 		seg_data <= SEG_4;
		4'd5: 		seg_data <= SEG_5;
		4'd6: 		seg_data <= SEG_6;
		4'd7: 		seg_data <= SEG_7;
		4'd8: 		seg_data <= SEG_8;
		4'd9: 		seg_data <= SEG_9;
		4'd12: 		seg_data <= SEG_C;
		/*
//		4'd10: 		seg_data <= SEG_A;
		4'd10: 		seg_data <= SEG_X;
		4'd11: 		seg_data <= SEG_B;
		4'd12: 		seg_data <= SEG_C;
		4'd13: 		seg_data <= SEG_D;
		4'd14: 		seg_data <= SEG_E;
		4'd15: 		seg_data <= SEG_F;*/
		default:	seg_data <= IDLE ;
	endcase

endmodule		

