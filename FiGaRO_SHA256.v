`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2023 01:46:18 PM
// Design Name: 
// Module Name: FiGaRO_SHA3
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


module FiGaRO_SHA3(
    input  wire reset,
    input  wire enable,
    input  wire clk,
    output reg ready,
    input  wire[10:0] ADDR,
    output reg[31:0] DATA_OUT
    );
    
  parameter CHUNK_SIZE = 1600;//32767;
  parameter NUMBER_OF_WORDS_SHA3INIT = CHUNK_SIZE / 32;
    
  parameter ADDR_CTRLADDR_CTRL        = 8'h08;
  parameter CTRL_INIT_VALUE  = 8'h01;
  parameter CTRL_NEXT_VALUE  = 8'h02;
  parameter CTRL_MODE_VALUE  = 8'h04;
  
  parameter ADDR_BLOCK0    = 6'h00;
  parameter ADDR_BLOCK1    = 6'h01;
  parameter ADDR_BLOCK2    = 6'h02;
  parameter ADDR_BLOCK3    = 6'h03;
  parameter ADDR_BLOCK4    = 6'h04;
  parameter ADDR_BLOCK5    = 6'h05;
  parameter ADDR_BLOCK6    = 6'h06;
  parameter ADDR_BLOCK7    = 6'h07;
  parameter ADDR_BLOCK8    = 6'h08;
  parameter ADDR_BLOCK9    = 6'h09;
  parameter ADDR_BLOCK10   = 6'h0a;
  parameter ADDR_BLOCK11   = 6'h0b;
  parameter ADDR_BLOCK12   = 6'h0c;
  parameter ADDR_BLOCK13   = 6'h0d;
  parameter ADDR_BLOCK14   = 6'h0e;
  parameter ADDR_BLOCK15   = 6'h0f;
  parameter ADDR_BLOCK16   = 6'h10;
  parameter ADDR_BLOCK17   = 6'h11;
  parameter ADDR_BLOCK18   = 6'h12;
  parameter ADDR_BLOCK19   = 6'h13;
  parameter ADDR_BLOCK20   = 6'h14;
  parameter ADDR_BLOCK21   = 6'h15;
  parameter ADDR_BLOCK22   = 6'h16;
  parameter ADDR_BLOCK23   = 6'h17;
  parameter ADDR_BLOCK24   = 6'h18;
  parameter ADDR_BLOCK25   = 6'h19;
  parameter ADDR_BLOCK26   = 6'h1a;
  parameter ADDR_BLOCK27   = 6'h1b;
  parameter ADDR_BLOCK28   = 6'h1c;
  parameter ADDR_BLOCK29   = 6'h1d;
  parameter ADDR_BLOCK30   = 6'h1e;
  parameter ADDR_BLOCK31   = 6'h1f;
  parameter ADDR_BLOCK32   = 6'h20;
  parameter ADDR_BLOCK33   = 6'h21;
  parameter ADDR_BLOCK34   = 6'h22;
  parameter ADDR_BLOCK35   = 6'h23;
  parameter ADDR_BLOCK36   = 6'h24;
  parameter ADDR_BLOCK37   = 6'h25;
  parameter ADDR_BLOCK38   = 6'h26;
  parameter ADDR_BLOCK39   = 6'h27;
  parameter ADDR_BLOCK40   = 6'h28;
  parameter ADDR_BLOCK41   = 6'h29;
  parameter ADDR_BLOCK42   = 6'h2a;
  parameter ADDR_BLOCK43   = 6'h2b;
  parameter ADDR_BLOCK44   = 6'h2c;
  parameter ADDR_BLOCK45   = 6'h2d;
  parameter ADDR_BLOCK46   = 6'h2e;
  parameter ADDR_BLOCK47   = 6'h2f;
  parameter ADDR_BLOCK48   = 6'h30;
  parameter ADDR_BLOCK49   = 6'h31;
  parameter ADDR_BLOCK50   = 6'h32;

  parameter ADDR_DIGEST0   = 6'h40;
  parameter ADDR_DIGEST1   = 6'h41;
  parameter ADDR_DIGEST2   = 6'h42;
  parameter ADDR_DIGEST3   = 6'h43;
  parameter ADDR_DIGEST4   = 6'h44;
  parameter ADDR_DIGEST5   = 6'h45;
  parameter ADDR_DIGEST6   = 6'h46;
  parameter ADDR_DIGEST7   = 6'h47;
  parameter ADDR_DIGEST8   = 6'h48;
  parameter ADDR_DIGEST9   = 6'h49;
  parameter ADDR_DIGESTA   = 6'h4a;
  parameter ADDR_DIGESTB   = 6'h4b;
  parameter ADDR_DIGESTC   = 6'h4c;
  parameter ADDR_DIGESTD   = 6'h4d;
  parameter ADDR_DIGESTE   = 6'h4e;
  parameter ADDR_DIGESTF   = 6'h4f;

    
localparam [3:0]
    starting                = 4'b0000,
    generating              = 4'b0001,
    generated               = 4'b0010,
    writing_to_sha          = 4'b0011,
    writed_to_sha           = 4'b0100,
    generating_hash         = 4'b0101,
    hash_generated          = 4'b0110,
    final_hash_generation   = 4'b0111,
    final_hash_generated    = 4'b1000,
    saving_hash             = 4'b1001,
    saved_hash              = 4'b1010,
    increment_counter       = 4'b1011,
    sending_data            = 4'b1100,
    data_sended             = 4'b1101;


    
reg[3:0] state;

//reg[33023:0] random_bits;
reg[1600:0] random_bits;
reg[16:0] generated_bits_counter;

reg[10:0] writed_words_counter;

reg[5:0] generating_hash_counter;

wire[10:0] writed_words_counter_wire; 
wire nreset;

reg[3:0] readed_words_counter; // zlicza słowa odczytane ze skrótu

reg          sha3_init;
reg          sha3_next;
wire          sha3_ready;
reg          sha3_we;
reg[7 : 0]   sha3_address;
reg[31 : 0]  sha3_din;
wire[31 : 0]  sha3_dout;

reg [511 : 0] digest_data;


    
//RANDOM GENERATORS     
wire gen1_out, gen2_out;//, gen3_out, gen4_out, gen5_out, gen6_out, gen7_out, gen8_out;
wire random_out;
    
FiGaRO generator1(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen1_out));
FiGaRO generator2(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen2_out));
// FiGaRO generator3(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen3_out));
// FiGaRO generator4(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen4_out));
// FiGaRO generator5(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen5_out));
// FiGaRO generator6(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen6_out));
// FiGaRO generator7(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen7_out));
// FiGaRO generator8(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen8_out));
assign random_out = gen1_out  ^ gen2_out;// ^ gen3_out ^ gen4_out ^ gen5_out ^ gen6_out ^ gen7_out ^ gen8_out;
//tutaj w zależności od dodatkowego parametru dajemy różne wyjścia:

//SHA3 
sha3 sha3_(
           .clk(clk),
           .nreset(nreset),
           .w(sha3_we),
           .addr(sha3_address),
           .din(sha3_din),
           .dout(sha3_dout),
           .init(sha3_init),
           .next(sha3_next),
           .ready(sha3_ready)
           );

//module sha3(    input wire          clk,
//                input wire 	     nreset,
//                input wire 	     w,
//                input wire [ 8:2]    addr,
//                input wire [32-1:0]  din,
//                output wire [32-1:0] dout,
//                input wire 	     init,
//                input wire 	     next,
//                output wire 	     ready);

assign writed_words_counter_wire = writed_words_counter;
assign nreset = !reset;

//STATE MACHINE
always @(posedge clk)
begin
    if(reset)
        begin
        state = starting;
        generated_bits_counter = 16'h0000;
        generating_hash_counter = 0;
        digest_data = 0;
        random_bits = 0;
        writed_words_counter = 0;
        readed_words_counter = 0;
        
        sha3_init = 0;
        sha3_next = 0;
        sha3_we = 0;
        sha3_address = 0;
        sha3_din = 0;
        end
    else
    begin
    case(state)
        starting: begin
            state <= generating;
        end
        
        generating: begin
            if(generated_bits_counter < CHUNK_SIZE)
            begin
                random_bits[generated_bits_counter] <= random_out;
                generated_bits_counter <= generated_bits_counter + 1;
            end
            if(generated_bits_counter == CHUNK_SIZE)
            begin
                state <= generated;
                generated_bits_counter <= 16'h0000; 
                sha3_we = 0;
                sha3_din <= 32'h00000000;
            end
         end
         
         generated: begin
            sha3_din = 32'h06000000;
            sha3_we = 1;
            state <= writing_to_sha;
         end
         
         writing_to_sha: begin//zapisywanie danych do sha po 32 bity ///3
            case(writed_words_counter[5:0])
                6'b000000 : sha3_address <= ADDR_BLOCK0;
                6'b000001 : sha3_address <= ADDR_BLOCK1;
                6'b000010 : sha3_address <= ADDR_BLOCK2;
                6'b000011 : sha3_address <= ADDR_BLOCK3;
                6'b000100 : sha3_address <= ADDR_BLOCK4;
                6'b000101 : sha3_address <= ADDR_BLOCK5;
                6'b000110 : sha3_address <= ADDR_BLOCK6;
                6'b000111 : sha3_address <= ADDR_BLOCK7;
                6'b001000 : sha3_address <= ADDR_BLOCK8;
                6'b001001 : sha3_address <= ADDR_BLOCK9;
                6'b001010 : sha3_address <= ADDR_BLOCK10;
                6'b001011 : sha3_address <= ADDR_BLOCK11;
                6'b001100 : sha3_address <= ADDR_BLOCK12;
                6'b001101 : sha3_address <= ADDR_BLOCK13;
                6'b001110 : sha3_address <= ADDR_BLOCK14;
                6'b001111 : sha3_address <= ADDR_BLOCK15;
                6'b010000 : sha3_address <= ADDR_BLOCK16;
                6'b010001 : sha3_address <= ADDR_BLOCK17;
                6'b010010 : sha3_address <= ADDR_BLOCK18;
                6'b010011 : sha3_address <= ADDR_BLOCK19;
                6'b010100 : sha3_address <= ADDR_BLOCK20;
                6'b010101 : sha3_address <= ADDR_BLOCK21;
                6'b010110 : sha3_address <= ADDR_BLOCK22;
                6'b010111 : sha3_address <= ADDR_BLOCK23;
                6'b011000 : sha3_address <= ADDR_BLOCK24;
                6'b011001 : sha3_address <= ADDR_BLOCK25;
                6'b011010 : sha3_address <= ADDR_BLOCK26;
                6'b011011 : sha3_address <= ADDR_BLOCK27;
                6'b011100 : sha3_address <= ADDR_BLOCK28;
                6'b011101 : sha3_address <= ADDR_BLOCK29;
                6'b011110 : sha3_address <= ADDR_BLOCK30;
                6'b011111 : sha3_address <= ADDR_BLOCK31;
                6'b100000 : sha3_address <= ADDR_BLOCK32;
                6'b100001 : sha3_address <= ADDR_BLOCK33;
                6'b100010 : sha3_address <= ADDR_BLOCK34;
                6'b100011 : sha3_address <= ADDR_BLOCK35;
                6'b100100 : sha3_address <= ADDR_BLOCK36;
                6'b100101 : sha3_address <= ADDR_BLOCK37;
                6'b100110 : sha3_address <= ADDR_BLOCK38;
                6'b100111 : sha3_address <= ADDR_BLOCK39;
                6'b101000 : sha3_address <= ADDR_BLOCK40;
                6'b101001 : sha3_address <= ADDR_BLOCK41;
                6'b101010 : sha3_address <= ADDR_BLOCK42;
                6'b101011 : sha3_address <= ADDR_BLOCK43;
                6'b101100 : sha3_address <= ADDR_BLOCK44;
                6'b101101 : sha3_address <= ADDR_BLOCK45;
                6'b101110 : sha3_address <= ADDR_BLOCK46;
                6'b101111 : sha3_address <= ADDR_BLOCK47;
                6'b110000 : sha3_address <= ADDR_BLOCK48;
                6'b110001 : sha3_address <= ADDR_BLOCK49;
                default : sha3_address <= ADDR_BLOCK0;
            endcase 
            
            case(writed_words_counter)
                10'h000 :  sha3_din <= 0;//random_bits[31:0];
                10'h001 :  sha3_din <= 1;//random_bits[63:32];
                10'h002 :  sha3_din <= 2;//random_bits[95:64];
                10'h003 :  sha3_din <= 3;//random_bits[127:96];
                10'h004 :  sha3_din <= 4;//4;//random_bits[159:128];
                10'h005 :  sha3_din <= 5;//random_bits[191:160];
                10'h006 :  sha3_din <= 6;//random_bits[223:192];
                10'h007 :  sha3_din <= 7;//random_bits[255:224];
                10'h008 :  sha3_din <= 8;//random_bits[287:256];
                10'h009 :  sha3_din <= 9;//random_bits[319:288];
                10'h00a :  sha3_din <= 10;//random_bits[351:320];
                10'h00b :  sha3_din <= 11;//random_bits[383:352];
                10'h00c :  sha3_din <= 12;//random_bits[415:384];
                10'h00d :  sha3_din <= 13;//random_bits[447:416];
                10'h00e :  sha3_din <= 14;//random_bits[479:448];
                10'h00f :  sha3_din <= 15;//random_bits[511:480];
                10'h010 :  sha3_din <= 16;//random_bits[543:512];
                10'h011 :  sha3_din <= 17;//random_bits[575:544];
                10'h012 :  sha3_din <= 18;//random_bits[607:576];
                10'h013 :  sha3_din <= 19;//random_bits[639:608];
                10'h014 :  sha3_din <= 20;//random_bits[671:640];
                10'h015 :  sha3_din <= 21;//random_bits[703:672];
                10'h016 :  sha3_din <= 22;//random_bits[735:704];
                10'h017 :  sha3_din <= 23;//random_bits[767:736];
                10'h018 :  sha3_din <= 24;//random_bits[799:768];
                10'h019 :  sha3_din <= 25;//random_bits[831:800];
                10'h01a :  sha3_din <= 26;//random_bits[863:832];
                10'h01b :  sha3_din <= 27;//random_bits[895:864];
                10'h01c :  sha3_din <= 28;//random_bits[927:896];
                10'h01d :  sha3_din <= 29;//random_bits[959:928];
                10'h01e :  sha3_din <= 30;//random_bits[991:960];
                10'h01f :  sha3_din <= 31;//random_bits[1023:992];
                10'h020 :  sha3_din <= 32;//random_bits[1055:1024];
                10'h021 :  sha3_din <= 33;//random_bits[1087:1056];
                10'h022 :  sha3_din <= 34;//random_bits[1119:1088];
                10'h023 :  sha3_din <= 35;//random_bits[1151:1120];
                10'h024 :  sha3_din <= 36;//random_bits[1183:1152];
                10'h025 :  sha3_din <= 37;//random_bits[1215:1184];
                10'h026 :  sha3_din <= 38;//random_bits[1247:1216];
                10'h027 :  sha3_din <= 39;//random_bits[1279:1248];
                10'h028 :  sha3_din <= 40;//random_bits[1311:1280];
                10'h029 :  sha3_din <= 41;//random_bits[1343:1312];
                10'h02a :  sha3_din <= 42;//random_bits[1375:1344];
                10'h02b :  sha3_din <= 43;//random_bits[1407:1376];
                10'h02c :  sha3_din <= 44;//random_bits[1439:1408];
                10'h02d :  sha3_din <= 45;//random_bits[1471:1440];
                10'h02e :  sha3_din <= 46;//random_bits[1503:1472];
                10'h02f :  sha3_din <= 47;//random_bits[1535:1504];
                10'h030 :  sha3_din <= 48;//random_bits[1567:1536];
                10'h031 :  sha3_din <= 49;//random_bits[1599:1568];
                default :  sha3_din <= random_bits[31:0];
            endcase
            writed_words_counter <= writed_words_counter + 1;
            sha3_we  <= 1;
            //if od zakończenia do wyliczenia skrótu
            if(writed_words_counter  == NUMBER_OF_WORDS_SHA3INIT)
            begin
                state <= writed_to_sha ;
                writed_words_counter  <= 0; 
                sha3_we <= 0;
                sha3_init <= 0;
            end
            
         end
         
         writed_to_sha: begin//dane zapisane ////4
            sha3_we <= 0;//opuszczenie flag zapisania do wewnętrznego rejestru
            sha3_address <= 0;
            sha3_din  <= 0;
            //TODO! w zależności, czy blok pierwszy czy kolejny zmienić, w szczególności dalej generować
            sha3_init <= 1;
            state <= generating_hash;
            
//            if(writed_words_counter == 8'hFF)
//            begin
//                state <= final_hash_generation;
//            end
//            else if(writed_words_counter_mod16  == 8'h00)
//            begin
//                state <= generating_hash;
//            end
//            else
//            begin
//                state <= writing_to_sha;
//                writed_words_counter <= writed_words_counter + 1;
//            end
//           case(writed_words_counter_wire)
//                10'b0000010000 : state <= generating_hash;//1
//                10'b0000100000 : state <= generating_hash;//2
//                10'b0000110000 : state <= generating_hash;//3
//                10'b0001000000 : state <= final_hash_generation;//4
//                // 10'b0001010000 : state <= generating_hash;//5
//                // 10'b0001100000 : state <= generating_hash;//6
//                // 10'b0001110000 : state <= generating_hash;//7
//                // 10'b0010000000 : state <= generating_hash;//8
//                // 10'b0010010000 : state <= generating_hash;//9
//                // 10'b0010100000 : state <= generating_hash;//a
//                // 10'b0010110000 : state <= generating_hash;//b
//                // 10'b0011000000 : state <= generating_hash;//c
//                // 10'b0011010000 : state <= generating_hash;//d
//                // 10'b0011100000 : state <= generating_hash;//e
//                // 10'b0011110000 : state <= generating_hash;//f
//                // 10'b0011111111 : state <= final_hash_generation;
//                default : begin state <= writing_to_sha; end
//            endcase 
         end
         
         generating_hash: begin//przeliczania po zapisaniu 50 bloków//5
            sha3_init <= 0;
            generating_hash_counter = generating_hash_counter + 1;
            if(generating_hash_counter == 63)
            begin
                state <= hash_generated;
                generating_hash_counter <= 0; 
            end
         end
         
         hash_generated: begin///6
            //TODO! WIELKI IF
            state <= saving_hash;//TODOdo zastanowienia
         end
         
         final_hash_generation: begin//7
            state <= final_hash_generated ;
         end
         
         final_hash_generated: begin//8
            state <= saving_hash;   
            writed_words_counter <= 0;              
         end

         saving_hash: begin//9
            case(readed_words_counter)
                4'h0 : begin sha3_address <= ADDR_DIGEST0; state <= saved_hash; end // zapisano wszystkie znaczące słowa
                4'h1 : begin sha3_address <= ADDR_DIGEST1;  state <= saved_hash; end
                4'h2 : begin sha3_address <= ADDR_DIGEST2;  state <= saved_hash; end
                4'h3 : begin sha3_address <= ADDR_DIGEST3;  state <= saved_hash; end
                4'h4 : begin sha3_address <= ADDR_DIGEST4;  state <= saved_hash; end
                4'h5 : begin sha3_address <= ADDR_DIGEST5;  state <= saved_hash; end
                4'h6 : begin sha3_address <= ADDR_DIGEST6;  state <= saved_hash; end
                4'h7 : begin sha3_address <= ADDR_DIGEST7;  state <= saved_hash; end
                4'h8 : state <= sending_data; // zapisano wszystkie znaczące słowa
                4'h9 : state <= sending_data; // zapisano wszystkie znaczące słowa
                default : sha3_address <= ADDR_DIGEST0;
            endcase
            sha3_we = 1;
         end
         
         saved_hash: begin//10
            case(readed_words_counter)
                4'h0 : begin digest_data[31:0] <= sha3_dout; end
                4'h1 : begin digest_data[63:32] <= sha3_dout; end
                4'h2 : begin digest_data[95:64] <= sha3_dout; end
                4'h3 : begin digest_data[127:96] <= sha3_dout; end
                4'h4 : begin digest_data[159:128] <= sha3_dout; end
                4'h5 : begin digest_data[191:160] <= sha3_dout;end
                4'h6 : begin digest_data[223:192] <= sha3_dout; end
                4'h7 : begin digest_data[255:224] <= sha3_dout; end
                4'h8 : begin digest_data[287:256] <= sha3_dout; end
                4'h9 : begin digest_data[319:288] <= sha3_dout; end
                4'hA : begin digest_data[351:320] <= sha3_dout; end
                4'hB : begin digest_data[383:352] <= sha3_dout; end
                4'hC : begin digest_data[415:384] <= sha3_dout; end
                4'hD : begin digest_data[447:416] <= sha3_dout; end
                4'hE : begin digest_data[479:448] <= sha3_dout; end
                4'hF : begin digest_data[511:480] <= sha3_dout; end
                default : digest_data[31:0] <= sha3_dout;
            endcase
            sha3_we = 0;
            state <= increment_counter;
         end
         
         increment_counter : begin
            readed_words_counter = readed_words_counter + 1;
            state <= saving_hash;
         end
         
         sending_data: begin
            ready <= 1;
            case(ADDR)
                11'h000 :  DATA_OUT <= random_bits[31:0];
                11'h001 :  DATA_OUT <= random_bits[63:32];
                11'h002 :  DATA_OUT <= random_bits[95:64];
                11'h003 :  DATA_OUT <= random_bits[127:96];
                11'h004 :  DATA_OUT <= random_bits[159:128];
                11'h005 :  DATA_OUT <= random_bits[191:160];
                11'h006 :  DATA_OUT <= random_bits[223:192];
                11'h007 :  DATA_OUT <= random_bits[255:224];
                11'h008 :  DATA_OUT <= random_bits[287:256];
                11'h009 :  DATA_OUT <= random_bits[319:288];
                11'h00a :  DATA_OUT <= random_bits[351:320];
                11'h00b :  DATA_OUT <= random_bits[383:352];
                11'h00c :  DATA_OUT <= random_bits[415:384];
                11'h00d :  DATA_OUT <= random_bits[447:416];
                11'h00e :  DATA_OUT <= random_bits[479:448];
                11'h00f :  DATA_OUT <= random_bits[511:480];
                11'h010 :  DATA_OUT <= random_bits[543:512];
                11'h011 :  DATA_OUT <= random_bits[575:544];
                11'h012 :  DATA_OUT <= random_bits[607:576];
                11'h013 :  DATA_OUT <= random_bits[639:608];
                11'h014 :  DATA_OUT <= random_bits[671:640];
                11'h015 :  DATA_OUT <= random_bits[703:672];
                11'h016 :  DATA_OUT <= random_bits[735:704];
                11'h017 :  DATA_OUT <= random_bits[767:736];
                11'h018 :  DATA_OUT <= random_bits[799:768];
                11'h019 :  DATA_OUT <= random_bits[831:800];
                11'h01a :  DATA_OUT <= random_bits[863:832];
                11'h01b :  DATA_OUT <= random_bits[895:864];
                11'h01c :  DATA_OUT <= random_bits[927:896];
                11'h01d :  DATA_OUT <= random_bits[959:928];
                11'h01e :  DATA_OUT <= random_bits[991:960];
                11'h01f :  DATA_OUT <= random_bits[1023:992];
                11'h020 :  DATA_OUT <= random_bits[1055:1024];
                11'h021 :  DATA_OUT <= random_bits[1087:1056];
                11'h022 :  DATA_OUT <= random_bits[1119:1088];
                11'h023 :  DATA_OUT <= random_bits[1151:1120];
                11'h024 :  DATA_OUT <= random_bits[1183:1152];
                11'h025 :  DATA_OUT <= random_bits[1215:1184];
                11'h026 :  DATA_OUT <= random_bits[1247:1216];
                11'h027 :  DATA_OUT <= random_bits[1279:1248];
                11'h028 :  DATA_OUT <= random_bits[1311:1280];
                11'h029 :  DATA_OUT <= random_bits[1343:1312];
                11'h02a :  DATA_OUT <= random_bits[1375:1344];
                11'h02b :  DATA_OUT <= random_bits[1407:1376];
                11'h02c :  DATA_OUT <= random_bits[1439:1408];
                11'h02d :  DATA_OUT <= random_bits[1471:1440];
                11'h02e :  DATA_OUT <= random_bits[1503:1472];
                11'h02f :  DATA_OUT <= random_bits[1535:1504];
                11'h030 :  DATA_OUT <= random_bits[1567:1536];
                11'h031 :  DATA_OUT <= random_bits[1599:1568];
                
                //ZAPISYWANIE HASHA
                11'h400 :  DATA_OUT <= digest_data[31:0];
                11'h401 :  DATA_OUT <= digest_data[63:32];
                11'h402 :  DATA_OUT <= digest_data[91:64];
                11'h403 :  DATA_OUT <= digest_data[127:96];
                11'h404 :  DATA_OUT <= digest_data[159:128];
                11'h405 :  DATA_OUT <= digest_data[191:160];
                11'h406 :  DATA_OUT <= digest_data[223:192];
                11'h407 :  DATA_OUT <= digest_data[255:224];
                11'h408 :  DATA_OUT <= digest_data[287:256];
                11'h409 :  DATA_OUT <= digest_data[319:288];
                11'h40a :  DATA_OUT <= digest_data[351:320];
                11'h40b :  DATA_OUT <= digest_data[383:352];
                11'h40c :  DATA_OUT <= digest_data[415:384];
                11'h40d :  DATA_OUT <= digest_data[447:416];
                11'h40e :  DATA_OUT <= digest_data[479:448];
                11'h40f :  DATA_OUT <= digest_data[511:480];
                
                //ODCZYTAŁEM WSZYSTKO, PRZECHODZĘ W STAN reset
                11'h7ff :  state <= data_sended;
                
                default :  DATA_OUT <= random_bits[31:0];
            endcase
         end
         
         data_sended : begin
            ready <= 0;
            state <= reset;
         end
    endcase
    end
end
//assign sha3_din = random_bits[writed_words_counter*(32+1):writed_words_counter*32];

endmodule
