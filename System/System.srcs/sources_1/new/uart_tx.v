`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/02 14:48:46
// Design Name: 
// Module Name: uart_tx
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



module uart_tx( 
    input					clk			,
    input					rst			,
    input       [7:0]   	tx_data 	,
    input               	tx_data_vld	,
    output  wire        	ready   	,
    output  reg         	tx              
);								 

parameter   MAX_BPS = 9600;
parameter   CLOCK = 50_000_000;
parameter   MAX_1bit = CLOCK/MAX_BPS;
parameter   CHECK_BIT = "None";

localparam  IDLE   = 'b00001,
            START  = 'b00010,
            DATA   = 'b00100,
            CHECK  = 'b01000,
            STOP   = 'b10000;
				
reg 	[4:0]		cstate     		;
reg		[4:0]		nstate     		;
    
wire				IDLE_START;
wire 				START_DATA;
wire 				DATA_CHECK;
wire 				CHECK_STOP;
wire				STOP_IDLE;
reg	[12:0]			cnt_baud	   	;
wire				add_cnt_baud	;
wire				end_cnt_baud	;
reg	[2:0]		cnt_bit	   			;
wire				add_cnt_bit		;
wire				end_cnt_bit		;
 
reg 	[3:0]   	bit_max			;
reg  	[7:0]   	tx_data_r		;
    
wire				check_val		;
    
//
always @(posedge clk or posedge rst)begin 
	if(rst)begin
		cnt_baud <= 'd0;
		end 
   else if(add_cnt_baud)begin 
      if(end_cnt_baud)begin 
			cnt_baud <= 'd0;
         end
      else begin 
         cnt_baud <= cnt_baud + 1'd1;
         end 
      end
   end 
    
assign add_cnt_baud = cstate != IDLE;
assign end_cnt_baud = add_cnt_baud && cnt_baud == MAX_1bit - 1'd1;
    
//
always @(posedge clk or posedge rst)begin 
   if(rst)begin
		cnt_bit <= 'd0;
		end 
	else if(add_cnt_bit)begin 
		if(end_cnt_bit)begin 
			cnt_bit <= 'd0;
			end
		else begin 
			cnt_bit <= cnt_bit + 1'd1;
			end 
		end
	end 
    
assign add_cnt_bit = end_cnt_baud;
assign end_cnt_bit = add_cnt_bit && cnt_bit == bit_max -1'd1;
    
//
always @(*)begin 
	case (cstate)
		IDLE :bit_max = 'd0;
		START:bit_max = 'd1;
		DATA :bit_max = 'd8;
		CHECK:bit_max = 'd1;
		STOP :bit_max = 'd1;
		default: bit_max = 'd0;
	endcase
end

assign IDLE_START = (cstate == IDLE) && tx_data_vld;
assign START_DATA = (cstate == START) && end_cnt_bit;
assign DATA_STOP = (cstate == DATA) && end_cnt_bit && CHECK_BIT == "None";
assign DATA_CHECK = (cstate == DATA) && end_cnt_bit;
assign CHECK_STOP = (cstate ==CHECK) && end_cnt_bit;
assign STOP_IDLE = (cstate == STOP) && end_cnt_bit;

//
always @(posedge clk or posedge rst)begin 
   if(rst)begin
		cstate <= IDLE;
		end 
   else begin 
		cstate <= nstate;
	end 
end
    
//FSM
always @(*) begin
	case(cstate)
		IDLE  :begin
			if (IDLE_START) begin
				nstate = START;
				end
			else begin
				nstate = cstate;
				end
			end
		START :begin
			if (START_DATA) begin
				nstate = DATA;
				end
			else begin
				nstate = cstate;
				end
			end
		DATA  :begin
			if (DATA_CHECK) begin
				nstate = CHECK;
					end
			else if (DATA_STOP) begin
				nstate = STOP;
				end
			else begin
				nstate = cstate;
				end
		end
		CHECK :begin
			if (CHECK_STOP) begin
				nstate = STOP;
				end
			else begin
				nstate = cstate;
				end
			end
		STOP  :begin
			if (STOP_IDLE) begin
				nstate = IDLE;
				end
			else begin
				nstate = cstate;
				end
			end
		default : nstate = cstate;
	endcase
end

//
always @(posedge clk or posedge rst) begin
	if (rst) begin
		tx_data_r <= 'd0;
		end
	else if (tx_data_vld) begin
		tx_data_r <= tx_data;
		end
	else begin
		tx_data_r <= tx_data_r;
		end
end
    
assign check_val = (CHECK_BIT == "Odd") ? ~^tx_data_r : ^tx_data_r;
    
//
always @(*)begin 
	case (cstate)
		IDLE : tx = 1'b1;
		START: tx = 1'b0;
		DATA : tx = tx_data_r[cnt_bit];
		CHECK: tx = check_val;
		STOP : tx = 1'b1;
	default: tx = 1'b1;
	endcase
end            


assign ready = cstate == IDLE;
     
endmodule

