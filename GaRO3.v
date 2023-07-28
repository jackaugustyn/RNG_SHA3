`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2023 09:36:21 AM
// Design Name: 
// Module Name: GaRO3
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


//module GaRO3(
//    input en,
//    input clk,
//    input dff_en,
//    output random_out
//    );
    
//wire random_out0;
//wire random_out1;
//wire random_out2;
//wire random_out3;
//wire random_out4;
//wire random_out5;
//wire random_out6;
//wire random_out7;
//wire random_out8;
//wire random_out9;
//wire random_out10;

//wire loop_from_f0_to_f10;
//wire loop_from_and_to_f0;
//wire loop_from_f1_to_and;
//wire loop_from_f2_to_f1;
//wire loop_from_f3_to_f2;
//wire loop_from_f4_to_f3;
//wire loop_from_f5_to_f4;
//wire loop_from_f6_to_f5;
//wire loop_from_f7_to_f6;
//wire loop_from_f8_to_f7;
//wire loop_from_f9_to_f8;
//wire loop_from_f10_to_f9;

//wire loop_x2;
//wire loop_x3;
//wire loop_x4;
//wire loop_x5;
//wire loop_x7;
//wire loop_x9;

//DFlipFlop FlipFlop0(.D(loop_from_f0_to_f10), .clk(clk), .E(dff_en), .Q(random_out0));
//DFlipFlop FlipFlop1(.D(loop_from_f1_to_and), .clk(clk), .E(dff_en), .Q(random_out1));
//DFlipFlop FlipFlop2(.D(loop_x2), .clk(clk), .E(dff_en), .Q(random_out2));
//DFlipFlop FlipFlop3(.D(loop_x3), .clk(clk), .E(dff_en), .Q(random_out3));
//DFlipFlop FlipFlop4(.D(loop_x4), .clk(clk), .E(dff_en), .Q(random_out4));
//DFlipFlop FlipFlop5(.D(loop_x5), .clk(clk), .E(dff_en), .Q(random_out5));
//DFlipFlop FlipFlop6(.D(loop_from_f6_to_f5), .clk(clk), .E(dff_en), .Q(random_out6));
//DFlipFlop FlipFlop7(.D(loop_x7), .clk(clk), .E(dff_en), .Q(random_out7));
//DFlipFlop FlipFlop8(.D(loop_from_f8_to_f7), .clk(clk), .E(dff_en), .Q(random_out8));
//DFlipFlop FlipFlop9(.D(loop_x9), .clk(clk), .E(dff_en), .Q(random_out9));
//DFlipFlop FlipFlop10(.D(loop_from_f10_to_f9), .clk(clk), .E(dff_en), .Q(random_out10));

//not(loop_from_f0_to_f10, loop_from_and_to_f0);//f0
//and(loop_from_and_to_f0, en, loop_from_f1_to_and);
//not(loop_from_f1_to_and, loop_x2);//f1
//xor(loop_x2, loop_from_f2_to_f1, loop_from_f0_to_f10);//x2
//not(loop_from_f2_to_f1, loop_x3);//f2
//xor(loop_x3, loop_from_f3_to_f2, loop_from_f0_to_f10);//x3
//not(loop_from_f3_to_f2, loop_x4);//f3
//xor(loop_x4, loop_from_f4_to_f3, loop_from_f0_to_f10);//x3
//not(loop_from_f4_to_f3, loop_x5);//f4
//xor(loop_x5, loop_from_f5_to_f4, loop_from_f0_to_f10);//x5
//not(loop_from_f5_to_f4, loop_from_f6_to_f5);//f5
//not(loop_from_f6_to_f5, loop_x7);//f6
//xor(loop_x7, loop_from_f7_to_f6, loop_from_f0_to_f10);//x7
//not(loop_from_f7_to_f6, loop_from_f8_to_f7);//f7
//not(loop_from_f8_to_f7, loop_x9);//f8
//xor(loop_x9, loop_from_f9_to_f8, loop_from_f0_to_f10);//x9
//not(loop_from_f9_to_f8, loop_from_f10_to_f9);//f9
//not(loop_from_f10_to_f9, loop_from_f0_to_f10);//f10


//assign random_out = random_out0 ^ random_out1 ^ random_out2 ^ random_out3 ^ random_out4 ^ random_out5 ^
//                    random_out6 ^ random_out7 ^ random_out8 ^ random_out9 ^ random_out10;

//endmodule

module GaRO3(
            input wire  clk,
            input wire en,
            output wire entropy
            );

  parameter POLY = 11'b10111101010;


  //----------------------------------------------------------------
  // Registers and wires.
  //----------------------------------------------------------------
  (* keep = "true" *) reg entropy_reg[10 : 0];
  (* keep = "true" *) wire [10 : 0] g;
  (* keep = "true" *) wire [10 : 0] gp;


  //---------------------------------------------------------------
  // Combinational loop inverters.
  //---------------------------------------------------------------
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv1  (.I0(g[0]),  .O(gp[0]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv2  (.I0(g[1]),  .O(gp[1]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv3  (.I0(g[2]),  .O(gp[2]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv4  (.I0(g[3]),  .O(gp[3]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv5  (.I0(g[4]),  .O(gp[4]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv6  (.I0(g[5]),  .O(gp[5]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv7  (.I0(g[6]),  .O(gp[6]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv8  (.I0(g[7]),  .O(gp[7]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv9  (.I0(g[8]),  .O(gp[8]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv10 (.I0(g[9]),  .O(gp[9]));
  (* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv11 (.I0(g[10]), .O(gp[10]));
  //(* keep = "true" *) SB_LUT4 #(.LUT_INIT(1'b1)) osc_inv12 (.I0(g[11]), .O(gp[11]));


  //---------------------------------------------------------------
  // parameterized feedback logic.
  //---------------------------------------------------------------
  (* keep = "true" *) assign g[10] = gp[0] & en;
  //(* keep = "true" *) assign g[10] = (gp[11] ^ (POLY[10] & gp[0])) & en;
  (* keep = "true" *) assign g[9]  = (gp[10] ^ (POLY[9]  & gp[0])) & en;
  (* keep = "true" *) assign g[8]  = (gp[9]  ^ (POLY[8]  & gp[0])) & en;
  (* keep = "true" *) assign g[7]  = (gp[8]  ^ (POLY[7]  & gp[0])) & en;
  (* keep = "true" *) assign g[6]  = (gp[7]  ^ (POLY[6]  & gp[0])) & en;
  (* keep = "true" *) assign g[5]  = (gp[6]  ^ (POLY[5]  & gp[0])) & en;
  (* keep = "true" *) assign g[5]  = (gp[6]  ^ (POLY[5]  & gp[0])) & en;
  (* keep = "true" *) assign g[4]  = (gp[5]  ^ (POLY[4]  & gp[0])) & en;
  (* keep = "true" *) assign g[3]  = (gp[4]  ^ (POLY[3]  & gp[0])) & en;
  (* keep = "true" *) assign g[2]  = (gp[3]  ^ (POLY[2]  & gp[0])) & en;
  (* keep = "true" *) assign g[1]  = (gp[2]  ^ (POLY[1]  & gp[0])) & en;
  (* keep = "true" *) assign g[0]  = (gp[1]  ^ (POLY[0]  & gp[0])) & en;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  (* keep = "true" *) assign entropy = entropy_reg[0] ^ entropy_reg[1] ^ entropy_reg[2] ^ entropy_reg[3] ^ entropy_reg[4]
                    ^ entropy_reg[5] ^ entropy_reg[6] ^ entropy_reg[7] ^ entropy_reg[8] ^ entropy_reg[9] ^ entropy_reg[10];


  //---------------------------------------------------------------
  // reg_update
  //---------------------------------------------------------------
  always @(posedge clk)
    begin : reg_update
      entropy_reg[0] <= g[0];
      entropy_reg[1] <= g[1];
      entropy_reg[2] <= g[2];
      entropy_reg[3] <= g[3];
      entropy_reg[4] <= g[4];
      entropy_reg[5] <= g[5];
      entropy_reg[6] <= g[6];
      entropy_reg[7] <= g[7];
      entropy_reg[8] <= g[8];
      entropy_reg[9] <= g[9];
      entropy_reg[10] <= g[10];
      //entropy_reg[11] <= g[11];
    end

endmodule // garo