`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2023 10:09:35 AM
// Design Name: 
// Module Name: FiGaRO_SHA3_tb
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


module FiGaRO_SHA3_tb();

  parameter CLK_HALF_PERIOD = 2;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg           tb_clk;
  reg           tb_enable;
  reg           tb_reset;
  wire           tb_ready;
  reg           tb_cs;
  reg           tb_we;
  reg [9 : 0]   tb_address;
  reg [31 : 0]  tb_write_data;
  wire [31 : 0] tb_read_data;
  wire          tb_error;

  reg [31 : 0]  read_data;
  reg [255 : 0] digest_data;
  
  
//module FiGaRO_SHA3(
//    input  wire reset,
//    input  wire enable,
//    input  wire clk,
//    output wire ready,
//    input  wire[9:0] ADDR,
//    output wire[31:0] DATA_OUT
//    );
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  FiGaRO_SHA3 dut(
            .reset(tb_reset),
            .enable(tb_enable),
            .clk(tb_clk),
            .ready(tb_ready),
            .ADDR(tb_address),
            .DATA_OUT(tb_read_data)
            );
            
  //----------------------------------------------------------------
  // clk_gen
  //
  // Clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD tb_clk = !tb_clk;
    end // clk_gen     
    
  always
    begin : sys_monitor
      #(2 * CLK_HALF_PERIOD);
      cycle_ctr = cycle_ctr + 1;
    end
    
     //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      cycle_ctr = 32'h0;
      tb_clk = 0;
      tb_reset = 0;
      tb_cs = 0;
      tb_we = 0;
      tb_enable = 1;
      tb_address = 10'h0;
      tb_write_data = 32'h0;
    end
  endtask // init_dut       

  task reset_dut;
    begin
      $display("*** Toggle reset.");
      tb_reset = 1;
      #(4 * CLK_HALF_PERIOD);
      tb_reset = 0;
    end
  endtask // reset_dut
  
  

initial
begin:main
      $display("   -- Testbench for sha256 started --");
      init_sim();
      reset_dut();
end
endmodule
