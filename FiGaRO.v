`timescale 1ns / 1ps
`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2023 10:13:23 AM
// Design Name: 
// Module Name: FiGaRO
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


module FiGaRO(
    input clk,
    input dff_en,
    input en,
    output random_out
    );
    

wire random_out1;
wire random_out2;
wire random_out3;
wire random_out4;
wire random_out5;
wire random_out6;
wire random_out7;
wire random_out8;

FiRO1 firo1(.en(en), .dff_en(dff_en), .clk(clk), .random_out(random_out1)); 
FiRO2 firo2(.en(en), .dff_en(dff_en), .clk(clk), .random_out(random_out2)); 
FiRO3 firo3(.en(en), .dff_en(dff_en), .clk(clk), .random_out(random_out3)); 
FiRO4 firo4(.en(en), .dff_en(dff_en), .clk(clk), .random_out(random_out4));  

GaRO1 garo1(.clk(clk), .en(en), .entropy(random_out5));
GaRO2 garo2(.clk(clk), .en(en), .entropy(random_out6));
GaRO3 garo3(.clk(clk), .en(en), .entropy(random_out7));
GaRO4 garo4(.clk(clk), .en(en), .entropy(random_out8));  

assign random_out = random_out1 ^ random_out2 ^ random_out3 ^ random_out4 ^ 
                    random_out5 ^ random_out6 ^ random_out7 ^ random_out8;

endmodule
