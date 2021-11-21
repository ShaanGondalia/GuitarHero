`timescale 1 ps / 100 fs
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
    
    VGAController vga(clock, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, t1, t2, t3, temp1[3:0], temp2[3:0], temp3[3:0], t4, t5, t6, t7);
    
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

    initial begin
        $display("Loading mem");
        $readmemh({FILES_PATH, "Notes.mem"}, NOTES);
        #8000000
        for(i = 0; i < 16; i = i + 1) begin
            #20;
            $display("notes: %b", NOTES[i]);
            $display("1st bit: %b", NOTES[i][3]);
        end
		$finish;
	end

    always
        #1 clock = !clock;

endmodule