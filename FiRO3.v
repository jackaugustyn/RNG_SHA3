`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: DKWOC
// Engineer: Paweł Augustynowicz
// 
// Create Date: 01/25/2023 10:36:31 AM
// Design Name: 
// Module Name: FibonnaciRingOscillator
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

module FiRO3(
    input en,
    input clk,
    input dff_en,
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
wire random_out9;
wire random_out10;

(* keep = "true" *) wire loop_from_f0_to_f1;
(* keep = "true" *) wire loop_from_f1_to_f2;
(* keep = "true" *) wire loop_from_f2_to_f3;
(* keep = "true" *) wire loop_from_f3_to_f4;
(* keep = "true" *) wire loop_from_f4_to_f5;
(* keep = "true" *) wire loop_from_f5_to_f6;
(* keep = "true" *) wire loop_from_f6_to_f7;
(* keep = "true" *) wire loop_from_f7_to_f8;
(* keep = "true" *) wire loop_from_f8_to_f9;
(* keep = "true" *) wire loop_from_f9_to_f10;

(* keep = "true" *) wire loop_x6;
(* keep = "true" *) wire loop_x5;
(* keep = "true" *) wire loop_x4;
(* keep = "true" *) wire loop_x3;
(* keep = "true" *) wire loop_x2;
(* keep = "true" *) wire loop_x1;

(* keep = "true" *) DFlipFlop FlipFlop1(.D(loop_from_f1_to_f2), .clk(clk), .E(dff_en), .Q(random_out1));
(* keep = "true" *) DFlipFlop FlipFlop2(.D(loop_from_f2_to_f3), .clk(clk), .E(dff_en), .Q(random_out2));
(* keep = "true" *) DFlipFlop FlipFlop3(.D(loop_from_f3_to_f4), .clk(clk), .E(dff_en), .Q(random_out3));
(* keep = "true" *) DFlipFlop FlipFlop4(.D(loop_from_f4_to_f5), .clk(clk), .E(dff_en), .Q(random_out4));
(* keep = "true" *) DFlipFlop FlipFlop5(.D(loop_from_f5_to_f6), .clk(clk), .E(dff_en), .Q(random_out5));
(* keep = "true" *) DFlipFlop FlipFlop6(.D(loop_from_f6_to_f7), .clk(clk), .E(dff_en), .Q(random_out6));
(* keep = "true" *) DFlipFlop FlipFlop7(.D(loop_from_f7_to_f8), .clk(clk), .E(dff_en), .Q(random_out7));
(* keep = "true" *) DFlipFlop FlipFlop8(.D(loop_from_f8_to_f9), .clk(clk), .E(dff_en), .Q(random_out8));
(* keep = "true" *) DFlipFlop FlipFlop9(.D(loop_from_f9_to_f10), .clk(clk), .E(dff_en), .Q(random_out9));
(* keep = "true" *) DFlipFlop FlipFlop10(.D(loop_from_f10_to_f0), .clk(clk), .E(dff_en), .Q(random_out10));

(* keep = "true" *) and(loop_from_f0_to_f1, en, loop_x1);//f0
(* keep = "true" *) not(loop_from_f1_to_f2,loop_from_f0_to_f1);//f1
(* keep = "true" *) not(loop_from_f2_to_f3,loop_from_f1_to_f2);//f2
(* keep = "true" *) not(loop_from_f3_to_f4,loop_from_f2_to_f3);//f3
(* keep = "true" *) not(loop_from_f4_to_f5,loop_from_f3_to_f4);//f4
(* keep = "true" *) not(loop_from_f5_to_f6,loop_from_f4_to_f5);//f5
(* keep = "true" *) not(loop_from_f6_to_f7,loop_from_f5_to_f6);//f6
(* keep = "true" *) not(loop_from_f7_to_f8,loop_from_f6_to_f7);//f7
(* keep = "true" *) not(loop_from_f8_to_f9,loop_from_f7_to_f8);//f8
(* keep = "true" *) not(loop_from_f9_to_f10,loop_from_f8_to_f9);//f9
(* keep = "true" *) not(loop_from_f10_to_f0,loop_from_f9_to_f10);//f10

xor(loop_x6, loop_from_f10_to_f0, loop_from_f6_to_f7);//x6
xor(loop_x5, loop_x6, loop_from_f5_to_f6);//x5
xor(loop_x4, loop_x5, loop_from_f4_to_f5);//x4
xor(loop_x3, loop_x4, loop_from_f3_to_f4);//x3
xor(loop_x2, loop_x3, loop_from_f2_to_f3);//x2
xor(loop_x1, loop_x2, loop_from_f1_to_f2);//x1

assign random_out = random_out1 ^ random_out2 ^ random_out3 ^ random_out4 ^ random_out5 ^
                    random_out6 ^ random_out7 ^ random_out8 ^ random_out9 ^ random_out10;

endmodule
