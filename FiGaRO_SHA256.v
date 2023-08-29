`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: DKWOC
// Engineer: P. J. Augustynowicz
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


module FiGaRO_SHA2_512(
    input  wire reset,
    input  wire enable,
    input  wire clk,
    output reg ready,
    input  wire[10:0] ADDR,
    output reg[31:0] DATA_OUT
    );
    
  parameter SAMPLE_SIZE = 32768;
  parameter CHUNK_SIZE = 1024;
  parameter NUMBER_OF_WORDS_SHA2 = CHUNK_SIZE / 32;
  //32767 / 576 = 56 blokow pelnych i 512 bitow w ostatnim;
  parameter NUMBER_OF_BLOCKS = SAMPLE_SIZE % CHUNK_SIZE == 0 ? (SAMPLE_SIZE / CHUNK_SIZE) + 1 : (SAMPLE_SIZE / CHUNK_SIZE);
  
  //Adresy kolejnych blokow danych do zapisu
  parameter ADDR_BLOCK0          = 8'h10;
  parameter ADDR_BLOCK1          = 8'h11;
  parameter ADDR_BLOCK2          = 8'h12;
  parameter ADDR_BLOCK3          = 8'h13;
  parameter ADDR_BLOCK4          = 8'h14;
  parameter ADDR_BLOCK5          = 8'h15;
  parameter ADDR_BLOCK6          = 8'h16;
  parameter ADDR_BLOCK7          = 8'h17;
  parameter ADDR_BLOCK8          = 8'h18;
  parameter ADDR_BLOCK9          = 8'h19;
  parameter ADDR_BLOCK10         = 8'h1a;
  parameter ADDR_BLOCK11         = 8'h1b;
  parameter ADDR_BLOCK12         = 8'h1c;
  parameter ADDR_BLOCK13         = 8'h1d;
  parameter ADDR_BLOCK14         = 8'h1e;
  parameter ADDR_BLOCK15         = 8'h1f;
  parameter ADDR_BLOCK16         = 8'h20;
  parameter ADDR_BLOCK17         = 8'h21;
  parameter ADDR_BLOCK18         = 8'h22;
  parameter ADDR_BLOCK19         = 8'h23;
  parameter ADDR_BLOCK20         = 8'h24;
  parameter ADDR_BLOCK21         = 8'h25;
  parameter ADDR_BLOCK22         = 8'h26;
  parameter ADDR_BLOCK23         = 8'h27;
  parameter ADDR_BLOCK24         = 8'h28;
  parameter ADDR_BLOCK25         = 8'h29;
  parameter ADDR_BLOCK26         = 8'h2a;
  parameter ADDR_BLOCK27         = 8'h2b;
  parameter ADDR_BLOCK28         = 8'h2c;
  parameter ADDR_BLOCK29         = 8'h2d;
  parameter ADDR_BLOCK30         = 8'h2e;
  parameter ADDR_BLOCK31         = 8'h2f;

  parameter ADDR_DIGEST0   = 8'h40;
  parameter ADDR_DIGEST1   = 8'h41;
  parameter ADDR_DIGEST2   = 8'h42;
  parameter ADDR_DIGEST3   = 8'h43;
  parameter ADDR_DIGEST4   = 8'h44;
  parameter ADDR_DIGEST5   = 8'h45;
  parameter ADDR_DIGEST6   = 8'h46;
  parameter ADDR_DIGEST7   = 8'h47;
  parameter ADDR_DIGEST8   = 8'h48;
  parameter ADDR_DIGEST9   = 8'h49;
  parameter ADDR_DIGESTA   = 8'h4a;
  parameter ADDR_DIGESTB   = 8'h4b;
  parameter ADDR_DIGESTC   = 8'h4c;
  parameter ADDR_DIGESTD   = 8'h4d;
  parameter ADDR_DIGESTE   = 8'h4e;
  parameter ADDR_DIGESTF   = 8'h4f;

    
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
    data_sended             = 4'b1101,
    zeroing                 = 4'b1110;

//rejestry i kable do logiki testów żywotności
reg health_tests_failed;
wire RepetitionCountTestFailed;
wire AdaptiveProportionTestFailed;
//maska wyboru zrodla losowosci
reg[4:0] mask;
//zmienna przechowujaca aktualny stan maszyny stanow
reg[3:0] state;
//zapisywanie trwa 2 takty, do rozroznienia, czy to pierwszy czy drugi takt
reg first_beat;
//dane zawarte sa w 64 blokach po 512 bitow (512 * 54 = 32768) plus 1 blok na padding
reg[6:0] block_number;

//dane generowane sa w paczkach po 512 bitow
reg[1023:0] random_bits;
//licznik, ile bitow z 32768 juz wygenerowano;
reg[16:0] generated_bits_counter;

//<! Licznik zapisanych do funkcji skrotu slow
reg[10:0] writed_words_counter;

//<! Licznik taktow oczekiwania na przetworzenie skrotu
reg[7:0] generating_hash_counter;

wire nreset;

reg[4:0] readed_words_counter; // zlicza slowa odczytane ze skrotu

reg sha2_cs;
reg sha2_we;
wire sha2_error;
reg[7:0] sha2_address;
reg[31:0] sha2_din;
wire[31:0] sha2_dout;

reg [511 : 0] digest_data;

//RANDOM GENERATORS     
wire gen1_out, gen2_out, gen3_out, gen4_out, gen5_out, gen6_out, gen7_out, gen8_out;
wire random_out;
    
FiGaRO generator1(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen1_out));
FiGaRO generator2(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen2_out));
FiGaRO generator3(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen3_out));
FiGaRO generator4(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen4_out));
FiGaRO generator5(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen5_out));
FiGaRO generator6(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen6_out));
FiGaRO generator7(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen7_out));
FiGaRO generator8(.clk(clk), .dff_en(enable), .en(enable), .random_out(gen8_out));


AdaptiveProportionTest APT(.random_bits(random_out), .index_of_last_bit(generated_bits_counter[9:0]), .failure(AdaptiveProportionTestFailed));
RepetitionCountTest RCT(.random_bits(random_out), .index_of_last_bit(generated_bits_counter[9:0]), .failure(RepetitionCountTestFailed));

//assign health_tests_failed = (health_tests_failed == 0) ?  AdaptiveProportionTestFailed || RepetitionCountTestFailed : 1; 

assign random_out = (mask == 1) ? gen1_out : 
                    (mask == 2) ? gen2_out : 
                    (mask == 3) ? gen3_out :
                    (mask == 4) ? gen4_out :
                    (mask == 5) ? gen5_out :
                    (mask == 6) ? gen6_out :
                    (mask == 7) ? gen7_out :
                    (mask == 8) ? gen8_out :
                    gen1_out  ^ gen2_out ^ gen3_out ^ gen4_out ^ gen5_out ^ gen6_out ^ gen7_out ^ gen8_out;
//tutaj w zaleznosci od dodatkowego parametru dajemy rozne wyjscia:

assign nreset = !reset;

sha512 sha2_(
            .clk(clk),
            .reset_n(nreset),
            .cs(sha2_cs),
            .we(sha2_we),
            .address(sha2_address),
            .write_data(sha2_din),
            .read_data(sha2_dout),
            .error(sha2_error)
            );



//MASZYNA STANoW
//PRZEBIEG GENERACJI:
//1. ROZPOCZECIE PROCESU: -> starting
//2. GENERACJA 576 bitow 
//3. UPDATE FUNKCJI SKROTU
// 3.1 Dla pierwszego bloku
// 3.2 Dla kolejnych blokow
// 3.3 Dla ostatniego bloku
//4. STAN ODBIORU ADDR
// 4.1 Gdy dane odebrane, generujemy kolejny blok
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
        
        health_tests_failed = 0;
        mask = 0;
        sha2_cs = 0;
        sha2_we  = 0;
        sha2_address = 0;
        sha2_din = 0;
        block_number  = 0;
        first_beat = 0;
        end
    else
    begin
    case(state)
        starting: begin
            generating_hash_counter = 0;
            writed_words_counter = 0;
            readed_words_counter = 0;
        
            health_tests_failed = 0;
            sha2_cs = 0;
            sha2_we  = 0;
            sha2_address = 0;
            sha2_din = 0;
            state <= generating;
        end
        
        //Stan generowania 
        generating: begin
            if(generated_bits_counter < CHUNK_SIZE)
            begin
                random_bits[generated_bits_counter] <= random_out;
                generated_bits_counter <= generated_bits_counter + 1;
                if(generated_bits_counter >= 1023)
                begin
                    health_tests_failed <= AdaptiveProportionTestFailed || RepetitionCountTestFailed || health_tests_failed;
                end
            end
            if(generated_bits_counter == CHUNK_SIZE)
            begin
                state <= generated;
                generated_bits_counter <= 16'h0000; 
                sha2_we = 0;
                sha2_din <= 32'h00000000;
            end
         end
         
         generated: begin
            sha2_we = 0;
            state <= writing_to_sha;
         end
         
         
         writing_to_sha: begin//zapisywanie danych do sha po 32 bity ///3
            case(writed_words_counter[5:0])
                6'b000000 : sha2_address <= ADDR_BLOCK0;
                6'b000001 : sha2_address <= ADDR_BLOCK1;
                6'b000010 : sha2_address <= ADDR_BLOCK2;
                6'b000011 : sha2_address <= ADDR_BLOCK3;
                6'b000100 : sha2_address <= ADDR_BLOCK4;
                6'b000101 : sha2_address <= ADDR_BLOCK5;
                6'b000110 : sha2_address <= ADDR_BLOCK6;
                6'b000111 : sha2_address <= ADDR_BLOCK7;
                6'b001000 : sha2_address <= ADDR_BLOCK8;
                6'b001001 : sha2_address <= ADDR_BLOCK9;
                6'b001010 : sha2_address <= ADDR_BLOCK10;
                6'b001011 : sha2_address <= ADDR_BLOCK11;
                6'b001100 : sha2_address <= ADDR_BLOCK12;
                6'b001101 : sha2_address <= ADDR_BLOCK13;
                6'b001110 : sha2_address <= ADDR_BLOCK14;
                6'b001111 : sha2_address <= ADDR_BLOCK15;
                6'b010000 : sha2_address <= ADDR_BLOCK16;
                6'b010001 : sha2_address <= ADDR_BLOCK17;
                6'b010010 : sha2_address <= ADDR_BLOCK18;
                6'b010011 : sha2_address <= ADDR_BLOCK19;
                6'b010100 : sha2_address <= ADDR_BLOCK20;
                6'b010101 : sha2_address <= ADDR_BLOCK21;
                6'b010110 : sha2_address <= ADDR_BLOCK22;
                6'b010111 : sha2_address <= ADDR_BLOCK23;
                6'b011000 : sha2_address <= ADDR_BLOCK24;
                6'b011001 : sha2_address <= ADDR_BLOCK25;
                6'b011010 : sha2_address <= ADDR_BLOCK26;
                6'b011011 : sha2_address <= ADDR_BLOCK27;
                6'b011100 : sha2_address <= ADDR_BLOCK28;
                6'b011101 : sha2_address <= ADDR_BLOCK29;
                6'b011110 : sha2_address <= ADDR_BLOCK30;
                6'b011111 : sha2_address <= ADDR_BLOCK31;
                default : sha2_address <= ADDR_BLOCK0;
            endcase 
            
            //32768 po 512 bitÃ³w absorbowanych naraz plus 1 blok na padding
            if(block_number < NUMBER_OF_BLOCKS - 1 )
            begin
                case(writed_words_counter)
                    10'h000 :  sha2_din <= 0;//random_bits[31:0];
                    10'h001 :  sha2_din <= 1;//random_bits[63:32];
                    10'h002 :  sha2_din <= 2;//random_bits[95:64];
                    10'h003 :  sha2_din <= 3;//random_bits[127:96];
                    10'h004 :  sha2_din <= 4;//random_bits[159:128];
                    10'h005 :  sha2_din <= 5;//random_bits[191:160];
                    10'h006 :  sha2_din <= 6;//random_bits[223:192];
                    10'h007 :  sha2_din <= 7;//random_bits[255:224];
                    10'h008 :  sha2_din <= 8;//random_bits[287:256];
                    10'h009 :  sha2_din <= 9;//random_bits[319:288];
                    10'h00a :  sha2_din <= 10;//random_bits[351:320];
                    10'h00b :  sha2_din <= 11;//random_bits[383:352];
                    10'h00c :  sha2_din <= 12;//random_bits[415:384];
                    10'h00d :  sha2_din <= 13;//random_bits[447:416];
                    10'h00e :  sha2_din <= 14;//random_bits[479:448];
                    10'h00f :  sha2_din <= 15;//random_bits[511:480];
                    
                    10'h010 :  sha2_din <= 16;//random_bits[543:512];
                    10'h011 :  sha2_din <= 17;//random_bits[575:544];
                    10'h012 :  sha2_din <= 18;//random_bits[607:576];
                    10'h013 :  sha2_din <= 19;//random_bits[639:608];
                    10'h014 :  sha2_din <= 20;//random_bits[671:640];
                    10'h015 :  sha2_din <= 21;//random_bits[703:672];
                    10'h016 :  sha2_din <= 22;//random_bits[735:704];
                    10'h017 :  sha2_din <= 23;//random_bits[767:736];
                    10'h018 :  sha2_din <= 24;//random_bits[799:768];
                    10'h019 :  sha2_din <= 25;//random_bits[831:800];
                    10'h01a :  sha2_din <= 26;//random_bits[863:832];
                    10'h01b :  sha2_din <= 27;//random_bits[895:864];
                    10'h01c :  sha2_din <= 28;//random_bits[927:896];
                    10'h01d :  sha2_din <= 29;//random_bits[959:928];
                    10'h01e :  sha2_din <= 30;//random_bits[991:960];
                    10'h01f :  sha2_din <= 31;//random_bits[1023:992];
                    default :  sha2_din <= 0; 
                endcase
            end
            else if(block_number == NUMBER_OF_BLOCKS - 1)// ostatni blok, wymagajÄcy paddingu
            begin
                case(writed_words_counter)
                    10'h000 :  sha2_din <= 32'h80000000;
                    10'h001 :  sha2_din <= 0;
                    10'h002 :  sha2_din <= 0;
                    10'h003 :  sha2_din <= 0;
                    10'h004 :  sha2_din <= 0;
                    10'h005 :  sha2_din <= 0;
                    10'h006 :  sha2_din <= 0;
                    10'h007 :  sha2_din <= 0;
                    10'h008 :  sha2_din <= 0;
                    10'h009 :  sha2_din <= 0;
                    10'h00a :  sha2_din <= 0;
                    10'h00b :  sha2_din <= 0;
                    10'h00c :  sha2_din <= 0;
                    10'h00d :  sha2_din <= 0;
                    10'h00e :  sha2_din <= 0;
                    10'h00f :  sha2_din <= 0;
                    
                    10'h011 :  sha2_din <= 0;
                    10'h012 :  sha2_din <= 0;
                    10'h013 :  sha2_din <= 0;
                    10'h014 :  sha2_din <= 0;
                    10'h015 :  sha2_din <= 0;
                    10'h016 :  sha2_din <= 0;
                    10'h017 :  sha2_din <= 0;
                    10'h018 :  sha2_din <= 0;
                    10'h019 :  sha2_din <= 0;
                    10'h01a :  sha2_din <= 0;
                    10'h01b :  sha2_din <= 0;
                    10'h01c :  sha2_din <= 0;
                    10'h01d :  sha2_din <= 0;
                    10'h01e :  sha2_din <= 0;
                    10'h01f :  sha2_din <= 32'h80000000;
                    default :  sha2_din <= 0;
                endcase
            end
            writed_words_counter <= writed_words_counter + 1;
            sha2_we <= 1;
            sha2_cs <= 1;
            
            //if od zakonczenia do wyliczenia skrÃ³tu
//            if(block_number  == 0 && writed_words_counter  == NUMBER_OF_WORDS_SHA3INIT)
//            begin
//                state <= writed_to_sha;
//                sha3_init <= 1;
//                writed_words_counter  <= 0; 
//                sha3_we  <= 0;
//            end
//            else if(block_number != 0 && writed_words_counter  == NUMBER_OF_WORDS_SHA3NEXT)
//            begin
//                state <= writed_to_sha ;
//                writed_words_counter <= 0; 
//                sha3_next <= 1;
//                sha3_we  <= 0;
//            end
            if(writed_words_counter == NUMBER_OF_WORDS_SHA2)
            begin
                state <= writed_to_sha;
                sha2_address <= 8'h08;
                sha2_din <= 32'h0000000d;
            end
         end
         //ZAPISYWANIE DO SHA TRWA 2 TAKTY
         writed_to_sha: 
         begin//dane zapisane ////4
            if(first_beat == 0)
            begin
                sha2_we <= 0;//opuszczenie flag zapisania do wewnetrznego rejestru
                sha2_cs <= 0;
                sha2_address <= 8'h08;
                sha2_din  <= 32'h0000000d;
                first_beat  <= 1;
            end
            else
            begin
                sha2_cs <= 1;
                sha2_address <= 8'h09;
                state <= generating_hash;
            end
         end
         
         generating_hash: 
         begin//przeliczania po zapisaniu 512 bitow//5
            first_beat <= 0;
            sha2_cs <= 1;
            sha2_address <= 8'h09;
            generating_hash_counter = generating_hash_counter + 1;
            
            if(generating_hash_counter > 161)
            begin
                state <= hash_generated;
                generating_hash_counter <= 0; 
            end
         end
         
         hash_generated: begin///6
            //TODO! WIELKI IF
            //stad mozna przejsc do odbioru danych, badz generacji ostatecznego hasha
            block_number <= block_number + 1;
            if(block_number < NUMBER_OF_BLOCKS)
            begin
                state <= saving_hash;//TODOdo zastanowienia
            end
            else
            begin
                state <= sending_data;
            end
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
                5'h00 : begin sha2_address <= ADDR_DIGEST0;  state <= saved_hash; digest_data[31:0]    <= sha2_dout; end // zapisano wszystkie znaczÄce sÅowa
                5'h01 : begin sha2_address <= ADDR_DIGEST1;  state <= saved_hash; digest_data[63:32]   <= sha2_dout; end
                5'h02 : begin sha2_address <= ADDR_DIGEST2;  state <= saved_hash; digest_data[95:64]   <= sha2_dout; end
                5'h03 : begin sha2_address <= ADDR_DIGEST3;  state <= saved_hash; digest_data[127:96]  <= sha2_dout; end
                5'h04 : begin sha2_address <= ADDR_DIGEST4;  state <= saved_hash; digest_data[159:128] <= sha2_dout; end
                5'h05 : begin sha2_address <= ADDR_DIGEST5;  state <= saved_hash; digest_data[191:160] <= sha2_dout; end
                5'h06 : begin sha2_address <= ADDR_DIGEST6;  state <= saved_hash; digest_data[223:192] <= sha2_dout; end
                5'h07 : begin sha2_address <= ADDR_DIGEST7;  state <= saved_hash; digest_data[255:224] <= sha2_dout; end
                5'h08 : begin sha2_address <= ADDR_DIGEST8;  state <= saved_hash; digest_data[287:256] <= sha2_dout; end
                5'h09 : begin sha2_address <= ADDR_DIGEST9;  state <= saved_hash; digest_data[319:288] <= sha2_dout; end            
                5'h0A : begin sha2_address <= ADDR_DIGESTA;  state <= saved_hash; digest_data[351:320] <= sha2_dout; end
                5'h0B : begin sha2_address <= ADDR_DIGESTB;  state <= saved_hash; digest_data[383:352] <= sha2_dout; end
                5'h0C : begin sha2_address <= ADDR_DIGESTC;  state <= saved_hash; digest_data[415:384] <= sha2_dout; end
                5'h0D : begin sha2_address <= ADDR_DIGESTD;  state <= saved_hash; digest_data[447:416] <= sha2_dout; end
                5'h0E : begin sha2_address <= ADDR_DIGESTE;  state <= saved_hash; digest_data[479:448] <= sha2_dout; end
                5'h0F : begin sha2_address <= ADDR_DIGESTF;  state <= saved_hash; digest_data[511:480] <= sha2_dout; end 
                default : sha2_address <= ADDR_DIGEST0;
            endcase
            state <= increment_counter;
         end
         
//         saved_hash: begin//10
//            case(readed_words_counter)
//                5'h00 : begin digest_data[31:0]    <= sha2_dout; end
//                5'h01 : begin digest_data[63:32]   <= sha2_dout; end
//                5'h02 : begin digest_data[95:64]   <= sha2_dout; end
//                5'h03 : begin digest_data[127:96]  <= sha2_dout; end
//                5'h04 : begin digest_data[159:128] <= sha2_dout; end
//                5'h05 : begin digest_data[191:160] <= sha2_dout;end
//                5'h06 : begin digest_data[223:192] <= sha2_dout; end
//                5'h07 : begin digest_data[255:224] <= sha2_dout; end
//                5'h08 : begin digest_data[287:256] <= sha2_dout; end
//                5'h09 : begin digest_data[319:288] <= sha2_dout; end
//                5'h0A : begin digest_data[351:320] <= sha2_dout; end
//                5'h0B : begin digest_data[383:352] <= sha2_dout; end
//                5'h0C : begin digest_data[415:384] <= sha2_dout; end
//                5'h0D : begin digest_data[447:416] <= sha2_dout; end
//                5'h0E : begin digest_data[479:448] <= sha2_dout; end
//                5'h0F : begin digest_data[511:480] <= sha2_dout; end
//                default : digest_data[31:0] <= sha2_dout;
//            endcase
//            sha3_we = 0;
//            state <= increment_counter;
//         end
         
         increment_counter : begin
            readed_words_counter = readed_words_counter + 1;
            //jeÅli nie wszystkie sÅowa zostaÅy zapisane:
            if(readed_words_counter < 5'h10)
            begin
                state <= saving_hash;
            end
            //wszystkie sÅowa zostaÅy zapisane
            if(readed_words_counter == 5'h10)
            begin
                state <= sending_data;
            end
         end
         
         sending_data: begin
            ready <= 1;
            readed_words_counter <= 5'h00;
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
                10'h012 :  DATA_OUT <= random_bits[607:576];
                10'h013 :  DATA_OUT <= random_bits[639:608];
                10'h014 :  DATA_OUT <= random_bits[671:640];
                10'h015 :  DATA_OUT <= random_bits[703:672];
                10'h016 :  DATA_OUT <= random_bits[735:704];
                10'h017 :  DATA_OUT <= random_bits[767:736];
                10'h018 :  DATA_OUT <= random_bits[799:768];
                10'h019 :  DATA_OUT <= random_bits[831:800];
                10'h01a :  DATA_OUT <= random_bits[863:832];
                10'h01b :  DATA_OUT <= random_bits[895:864];
                10'h01c :  DATA_OUT <= random_bits[927:896];
                10'h01d :  DATA_OUT <= random_bits[959:928];
                10'h01e :  DATA_OUT <= random_bits[991:960];
                10'h01f :  DATA_OUT <= random_bits[1023:992];
                
                //BADANIE ENTROPII
                11'h100 :  mask <= 0;
                11'h101 :  mask <= 1;
                11'h102 :  mask <= 2;
                11'h103 :  mask <= 3;
                11'h104 :  mask <= 4;
                11'h105 :  mask <= 5;
                11'h106 :  mask <= 6;
                11'h107 :  mask <= 7;
                11'h108 :  mask <= 8;
                
                //SPRAWDZENIE STANU HEALTH TESTÓW:
                11'h201 : DATA_OUT <= {31'h0, health_tests_failed};
                
                //ODCZYTYWANIE SKROTU
                11'h400 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[31:0];
                11'h401 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[63:32];
                11'h402 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[91:64];
                11'h403 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[127:96];
                11'h404 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[159:128];
                11'h405 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[191:160];
                11'h406 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[223:192];
                11'h407 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[255:224];
                11'h408 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[287:256];
                11'h409 :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[319:288];
                11'h40a :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[351:320];
                11'h40b :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[383:352];
                11'h40c :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[415:384];
                11'h40d :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[447:416];
                11'h40e :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[479:448];
                11'h40f :  DATA_OUT <= (health_tests_failed) ? 0 : digest_data[511:480];
                
                //ODCZYTALEM SKROT I DANE, ZABAWA OD ADDR
                11'h3FF : state <= zeroing ;
                
                //ODCZYTALEM DANE, PRZECHODZE W STAN POCZATKOWY STARTING
                11'h7ff :  state <= data_sended;
                
                default :  DATA_OUT <= random_bits[31:0];
            endcase
            //DEBUG PURPOSE
            state <= data_sended;
         end
         
         data_sended : begin
            ready <= 0;
            state <= starting;
         end
         
         zeroing : begin
            block_number <= 0;
            state <= starting;
         end
    endcase
    end
end
//assign sha3_din = random_bits[writed_words_counter*(32+1):writed_words_counter*32];

endmodule