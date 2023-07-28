//////////////////////////////////////////////////////////////////////////////////
// Company: DKWOC
// Engineer: Paweł Augusytnowicz
// 
// Create Date: 01/25/2023 10:25:43 AM
// Design Name: Ring Oscillator Random Number Generator
// Module Name: DFlipFlop
// Project Name: 
// Target Devices: Alveo 250
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


module DFlipFlop(
    input D,
    input clk,
    input E,
    output reg Q
    );
always @(posedge clk)
begin
    if(E==1'b1)
        Q <= 1'b0;
    else
        Q <= D;
end
endmodule
