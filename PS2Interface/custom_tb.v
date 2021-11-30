`timescale 100 ps / 10 ps
module custom_tb;
    wire [31:0] in0, in1, in2, in3, in4, in5, in6, in7;

    reg clock = 0;

    wire [31:0] temp1, temp2, temp3, temp4, temp5, temp6;
    wire t1, t2, t3, t4, t5, t6, t7;
	
	integer i;

    integer m0;
    integer m1;
    integer m2;
    integer m3;
    integer m4;
    integer m5;


    assign in0 = m0;
    assign in1 = m1;
    assign in2 = m2;

    ///////////////////
    //
    // iverilog -o f_custom_tb.vvp -s custom_tb custom_tb.v
    //
    ///////////////////
    
    // VGAController vga(clock, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, t1, t2, t3, temp1[3:0], temp2[3:0], temp3[3:0], t4, t5, t6, t7);
    
//    VGAController(input clk, 			// 100 MHz System Clock
//	input reset, 		// Reset Signal
//	input move_up,
//	input move_down,
//	input move_right,
//	input move_left,
//	output debug1,
//	output hSync, 		// H Sync Signal
//	output vSync, 		// Veritcal Sync Signal
//	output[3:0] VGA_R,  // Red Signal Bits
//	output[3:0] VGA_G,  // Green Signal Bits
//	output[3:0] VGA_B,  // Blue Signal Bits
//	inout ps2_clk,
//	inout ps2_data);
    localparam FILES_PATH = "C:/Users/fj32/OneDrive - Duke University/Documents/guitar_hero/GuitarHero/PS2Interface/";
    localparam MAX_NOTES_ON_SCREEN = 21;
    reg[3:0] NOTES[0:MAX_NOTES_ON_SCREEN - 1];
    wire [MAX_NOTES_ON_SCREEN-1:0] felix;
    assign felix = m0[MAX_NOTES_ON_SCREEN-1:0];
    assign hi =|felix;
    reg[3:0] maybe;

    assign temp2 = m0;

    bin2bcd ftest(temp2[13:0], temp1[15:0]);

    initial begin
        for(i = 0; i < 16; i = i + 1) begin
            m0 = i;
            #20;
			$display("integer: %3d binary: %b bcd: %b", i, temp2[13:0], temp1[15:0]);
        end
		$finish;
	end

    integer imove;
    // initial begin
    //     m0 = 0;
    //     #20
    //     $display("Loading mem %b", hi);
    //     // $readmemh({FILES_PATH, "Notes.mem"}, NOTES);
    //     $readmemh("Notes.mem", NOTES);
    //     #10
    //     for(i = 0; i < 16; i = i + 1) begin
    //         #20;
    //         maybe = $urandom%2;
	// 		m1 = maybe ? (-1 * i * 64) : (i * 64);
	// 		$display("maybe: %b m1: %b", maybe, m1);
    //         // $display("i: %d notes: %b", i, NOTES[i]);
    //         // $display("1st bit: %b", NOTES[i][3]);
    //         // if(NOTES[i][3] == 0) begin
    //         //     $display("zero %b", felix);
    //         // end else begin
    //         //     $display("not zero %b", felix);
    //         // end
    //     end
	// 	$finish;
	// end

    // reg[31:0] NOTE_POS1[0:39];
    // reg[31:0] NOTE_POS2[0:39];
    // reg NOTE_SPEED = 1;
    // always @(posedge clock) begin
	// 	for(imove = 0; imove < 40; imove = imove + 1) begin
	// 		NOTE_POS1[imove] = NOTE_POS1[imove] + NOTE_SPEED;
    //         NOTE_POS2[imove] = NOTE_POS2[imove] + NOTE_SPEED;
	// 	end
	// end

    // always @(posedge clock) begin
    //     $display("integer: %b", m0);
    //     for(i = 0; i < MAX_NOTES_ON_SCREEN; i = i + 1) begin
    //         m0[i] = ~m0[i];
    //     end
    //     $display("integer: %b", m0);
    // end

    always
        #40 clock = !clock;

endmodule