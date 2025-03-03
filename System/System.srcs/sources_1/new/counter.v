`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/02 13:46:31
// Design Name: 
// Module Name: counter
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


module counter(
    input   wire    clk,
    input   wire    rst,
    input   wire    [2:0]   Key,
    output  wire    LED,
    output  reg     [9:0]   count 
    );
  

  reg flag;//0£ºÆô¶¯£»1£ºÍ£Ö¹
  assign LED = flag;  
  
  always @ (posedge clk, posedge rst)
    begin
      if(rst)
        flag <= 1'b0;
      else if(!Key[0])
        flag <= ~flag;
      else ;
    end
  
  always @ (posedge clk, posedge rst)
    begin
      if(rst)
        count <= 10'b0;
      else if((!flag) && (!Key[0]))
        ;//Í£Ö¹
      else if(flag && (!Key[0]))
        ;//Æô¶¯
      else if(flag && (!Key[2]))
        begin
          if(count == 10'd0) count <= 10'd999;
          else count <= count - 10'b1;
        end
      else if((!flag) && (!Key[1]))
        begin
          if(count == 10'd999) count <= 10'd0;
          else count <= count + 10'b1;
        end
      else
        ;
    end
  
  
  
  
endmodule
