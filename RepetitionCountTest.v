`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2023 02:35:20 PM
// Design Name: 
// Module Name: RepetitionCountTest
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


module RepetitionCountTest(
    input wire[1023:0] random_bits,
    input wire[9:0] index_of_last_bit,
    output wire failure
    );


    assign failure =   (random_bits[index_of_last_bit    ]         == random_bits[(index_of_last_bit-1)% 1024]) && 
                        (random_bits[(index_of_last_bit -1) % 1024] == random_bits[(index_of_last_bit-2)% 1024]) &&
                        (random_bits[(index_of_last_bit -2) % 1024] == random_bits[(index_of_last_bit-3)% 1024]) &&
                        (random_bits[(index_of_last_bit - 3) % 1024] == random_bits[(index_of_last_bit - 4)% 1024]) &&
                        (random_bits[(index_of_last_bit - 4) % 1024] == random_bits[(index_of_last_bit - 5)% 1024]) &&
                        (random_bits[(index_of_last_bit - 5) % 1024] == random_bits[(index_of_last_bit - 6)% 1024]) &&
                        (random_bits[(index_of_last_bit - 6) % 1024] == random_bits[(index_of_last_bit - 7)% 1024]) &&
                        (random_bits[(index_of_last_bit - 7) % 1024] == random_bits[(index_of_last_bit - 8)% 1024]) &&
                        (random_bits[(index_of_last_bit - 8) % 1024] == random_bits[(index_of_last_bit - 9)% 1024]) &&
                        (random_bits[(index_of_last_bit - 9) % 1024] == random_bits[(index_of_last_bit - 10)% 1024]) &&
                        (random_bits[(index_of_last_bit - 10) % 1024] == random_bits[(index_of_last_bit - 11)% 1024]) &&
                        (random_bits[(index_of_last_bit - 11) % 1024] == random_bits[(index_of_last_bit - 12)% 1024]) &&
                        (random_bits[(index_of_last_bit - 12) % 1024] == random_bits[(index_of_last_bit - 13)% 1024]) &&
                        (random_bits[(index_of_last_bit - 13) % 1024] == random_bits[(index_of_last_bit - 14)% 1024]) &&
                        (random_bits[(index_of_last_bit - 14) % 1024] == random_bits[(index_of_last_bit - 15)% 1024]) &&
                        (random_bits[(index_of_last_bit - 15) % 1024] == random_bits[(index_of_last_bit - 16)% 1024]) &&
                        (random_bits[(index_of_last_bit - 16) % 1024] == random_bits[(index_of_last_bit - 17)% 1024]) &&
                        (random_bits[(index_of_last_bit - 17) % 1024] == random_bits[(index_of_last_bit - 18)% 1024]) &&
                        (random_bits[(index_of_last_bit - 18) % 1024] == random_bits[(index_of_last_bit - 19)% 1024]) &&
                        (random_bits[(index_of_last_bit - 19) % 1024] == random_bits[(index_of_last_bit - 20)% 1024]) &&
                        (random_bits[(index_of_last_bit - 20) % 1024] == random_bits[(index_of_last_bit - 21)% 1024]) &&
                        (random_bits[(index_of_last_bit - 21) % 1024] == random_bits[(index_of_last_bit - 22)% 1024]);

endmodule
