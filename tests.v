`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2025 23:24:43
// Design Name: 
// Module Name: tests
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


module tests();
reg clk,rst;
wire [31:0]wb,addr_out,rs_out,rd,data,outer,mwb;
datapath_32 jiji(clk,rst,wb,outer,mwb,addr_out,rs_out,rd,data);
initial begin
clk=0;
rst=1;
#10
rst=0;
end
always#5 clk=~clk;
endmodule
