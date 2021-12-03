`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	input move_up,
	input move_down,
	input move_right,
	input move_left,
	input [3:0] buttons,
	input strum,
	output [3:0] buttonsHigh,
	output debug1,
	output debug2,
	output debug3,
	output debug4,
	output [7:0] cathode,     // for LED
	output [7:0] anode,       // for LED
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data);
	
	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/fj32/OneDrive - Duke University/Documents/guitar_hero3/GuitarHero/PS2Interface/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

    // these are provided by the VGATimingGenerator, x and y are current x and y that we scan over
	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr; 	 // Color address for the color palette
	assign imgAddress = x + 640*y;				 // Address calculated coordinate

	RAMVGA #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
	ImageData(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress),					 // Image data address
		.dataOut(colorAddr),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel

	RAMVGA #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
	ColorPalette(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr),					       // Address from the ImageData RAM
		.dataOut(colorData),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always active
		
	
	// begin my code:
	
	// in order to draw blocks moving down, need registers to store their coordinate and their color
	// need to store the coordinate of EACH block and then destroy them when they exit screen
	// can use array of registers like audioController, maybe initialize to some high value to indicate that no block is at that stage
	
	// code below from audio controller
	/* // Initialize the frequency array. FREQs[0] = 261
	reg[10:0] FREQs[0:15];
	initial begin
		$readmemh("FREQs.mem", FREQs);
	end
	integer index = 0;
	
	always @(posedge clk) begin
	   index = switches; // assign 4 bits to an integer
	   CounterLimit <= SYSTEM_FREQ / (2 * FREQs[index]) - 1;
    */

	// screen clock: how often to move pieces (25MHz clock is for VGATimingGenerator, not this clock)
	reg screen_clock = 0; // 60 Hz clock
	reg[26:0] screen_counter = 0;
	reg[26:0] screen_limit; // = 833332; // 100 MHz -> 60 Hz need counter limit = 100 000 000 / (2 * 60) - 1
    reg[13:0] speed = 60; // the frequency of the screen clock

    reg led_clock = 0;
	reg[26:0] led_counter = 0;
	reg[26:0] led_limit = 100000000 / (2 * 10000);
    
    localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency
	
	// Clock divider for processor (Running at 1 Mhz)
	reg[23:0] ProcCounterLimit;
	reg procclk = 0;
	reg[23:0] proccounter = 0;
    
	// clock divider
	always @(posedge clk) begin
	    screen_limit = SYSTEM_FREQ / (2 * speed) - 1;
		if(screen_counter < screen_limit)
	       screen_counter <= screen_counter + 1;
	   	else begin
	       screen_counter <= 0;
	       screen_clock <= ~screen_clock;
	   	end
	   	if(led_counter < led_limit)
	       led_counter <= led_counter + 1;
	   	else begin
	       led_counter <= 0;
	       led_clock <= ~led_clock;
	   	end
	   	
	   	ProcCounterLimit = SYSTEM_FREQ / (2*MHz - 1);
        if(proccounter < ProcCounterLimit)
	       proccounter <= proccounter + 1;
        else begin
	       proccounter <=0;
	       procclk <= ~procclk;
        end
	end

	reg[3:0] NOTES[0:62];
	localparam MAX_NOTES_ON_SCREEN = 4;
	reg[31:0] NOTE_POS1[0:MAX_NOTES_ON_SCREEN - 1]; // top left corner of y positon of notes
	reg[31:0] NOTE_POS2[0:MAX_NOTES_ON_SCREEN - 1];
	reg[31:0] NOTE_POS3[0:MAX_NOTES_ON_SCREEN - 1];
	reg[31:0] NOTE_POS4[0:MAX_NOTES_ON_SCREEN - 1];
	
    reg NOTE_SPEED = 1;
	reg[9:0] NOTE_1_X = 170;
	reg[9:0] NOTE_2_X = 270;
	reg[9:0] NOTE_3_X = 370;
	reg[9:0] NOTE_4_X = 470;
	reg[6:0] NOTE_WIDTH = 50;
	
	wire speed_up;
	wire speed_down;
	wire level_up;
	wire level_down;
	debounce speed_up_button(clk, move_up, speed_up);
	debounce speed_down_button(clk, move_down, speed_down);
	debounce level_up_button(clk, move_right, level_up);
	debounce level_down_button(clk, move_left, level_down);
    
    // only shows 2 digits but 14 bits just for ease into seven segment
    reg[13:0] level = 0;

    // move notes
	integer imove;
	always @(posedge screen_clock) begin
	    // vivado doesn't like i++
//	    one = one + NOTE_SPEED;
//	    two = two + NOTE_SPEED;
		 for(imove = 0; imove < MAX_NOTES_ON_SCREEN; imove = imove + 1) begin
		 	NOTE_POS1[imove] = NOTE_POS1[imove] + NOTE_SPEED;
		 	NOTE_POS2[imove] = NOTE_POS2[imove] + NOTE_SPEED;
		 	NOTE_POS3[imove] = NOTE_POS3[imove] + NOTE_SPEED;
		 	NOTE_POS4[imove] = NOTE_POS4[imove] + NOTE_SPEED;
		 end
		 
		 if (reset) begin
		    speed = 60;
		    if(level == 1) begin
		    // all notes
		        NOTE_POS1[0] = 0;
                NOTE_POS2[0] = 0;
                NOTE_POS3[0] = 0;
                NOTE_POS4[0] = 0;
                NOTE_POS1[1] = -100;
                NOTE_POS2[1] = -100;
                NOTE_POS3[1] = -100;
                NOTE_POS4[1] = -100;
                NOTE_POS1[2] = -200;
                NOTE_POS2[2] = -200;
                NOTE_POS3[2] = -200;
                NOTE_POS4[2] = -200;
                NOTE_POS1[3] = -300;
                NOTE_POS2[3] = -300;
                NOTE_POS3[3] = -300;
                NOTE_POS4[3] = -300;
		    end else if(level == 2) begin
		    // heart
		        NOTE_POS2[0] = 0;
                NOTE_POS3[0] = 0;
                NOTE_POS1[0] = -100;
                NOTE_POS4[0] = -100;
                NOTE_POS1[1] = -200;
                NOTE_POS4[1] = -200;
                NOTE_POS2[1] = -300;
                NOTE_POS3[1] = -300;
                NOTE_POS1[2] = -400;
                NOTE_POS2[2] = -400;
                NOTE_POS3[2] = -400;
                NOTE_POS4[2] = -400;
                NOTE_POS1[3] = -500;
                NOTE_POS2[3] = -500;
                NOTE_POS3[3] = -500;
                NOTE_POS4[3] = -500;
		    end else if(level == 3) begin
		    // X
		        NOTE_POS1[0] = 0;
                NOTE_POS4[0] = 0;
                NOTE_POS2[0] = -100;
                NOTE_POS3[0] = -100;
                NOTE_POS2[1] = -200;
                NOTE_POS3[1] = -200;
                NOTE_POS1[1] = -300;
                NOTE_POS4[1] = -300;
                NOTE_POS1[2] = -400;
                NOTE_POS2[2] = -400;
                NOTE_POS3[2] = -400;
                NOTE_POS4[2] = -400;
                NOTE_POS1[3] = -500;
                NOTE_POS2[3] = -500;
                NOTE_POS3[3] = -500;
                NOTE_POS4[3] = -500;
		    end else begin
		    // single notes
		        NOTE_POS4[0] = 0;
                NOTE_POS3[0] = -100;
                NOTE_POS2[0] = -200;
                NOTE_POS1[0] = -300;
                NOTE_POS4[1] = -400;
                NOTE_POS3[1] = -500;
                NOTE_POS2[1] = -600;
                NOTE_POS1[1] = -700;
                NOTE_POS4[2] = -800;
                NOTE_POS3[2] = -900;
                NOTE_POS2[2] = -1000;
                NOTE_POS1[2] = -1100;
                NOTE_POS4[3] = -1200;
                NOTE_POS3[3] = -1300;
                NOTE_POS2[3] = -1400;
                NOTE_POS1[3] = -1500;
		    end
		 end
		 
		 if(speed_up) begin
		      speed = speed + 2;
		 end
		 
		 if(speed_down) begin
		      speed = speed - 2;
		 end
		 
		 if(level_up) begin
		      level = level + 1;
		 end
		 
		 if(level_down) begin
		      level = level - 1;
		 end
	end
	

	// top left of square x and y, and then square width
//	reg[9:0] xtl = VIDEO_WIDTH / 2;
//	reg[8:0] ytl = VIDEO_HEIGHT / 2;
//	reg[6:0] width = 100;
	// square color is 12'b111100000000; red is f, green and blue are 0
//    always @(posedge screenEnd) begin
//         ytl = move_up ? ytl - 1 : ytl;
//         ytl = move_down ? ytl + 1 : ytl;
//         xtl = move_left ? xtl - 1 : xtl;
//         xtl = move_right ? xtl + 1 : xtl;
//         if (ytl < 2)
//             ytl = 2;
//         if (xtl < 2)
//             xtl = 2;
//         if (ytl + width > VIDEO_HEIGHT)
//             ytl = VIDEO_HEIGHT - width;
//         if (xtl + width > VIDEO_WIDTH)
//             xtl = VIDEO_WIDTH - width;
//    end

    // draw line for notes to be played
	reg [9:0] horLineX = 120;
	reg [9:0] horLineY = 350;
	reg [9:0] horLineWidthX = 400;
	reg [9:0] horLineWidthY = 20;
	wire horLine;
	check_flex_bounds hor_line(horLine, horLineX, horLineY, horLineWidthX, horLineWidthY, x, y);

	wire [MAX_NOTES_ON_SCREEN-1:0] inNote1, inNote2, inNote3, inNote4; // each bit is high if current x and y are in the note in NOTE_POS
    genvar g;
    generate
        for (g = 0; g < MAX_NOTES_ON_SCREEN; g = g + 1) begin: loop1
			check_bounds note1(inNote1[g], NOTE_1_X, NOTE_POS1[g], NOTE_WIDTH, x, y);
			check_bounds note2(inNote2[g], NOTE_2_X, NOTE_POS2[g], NOTE_WIDTH, x, y);
			check_bounds note3(inNote3[g], NOTE_3_X, NOTE_POS3[g], NOTE_WIDTH, x, y);
			check_bounds note4(inNote4[g], NOTE_4_X, NOTE_POS4[g], NOTE_WIDTH, x, y);
        end
    endgenerate
    wire [MAX_NOTES_ON_SCREEN-1:0] playNote1, playNote2, playNote3, playNote4;
    generate
        for (g = 0; g < MAX_NOTES_ON_SCREEN; g = g + 1) begin: loop2
            intersect check_int1(playNote1[g], NOTE_POS1[g], NOTE_WIDTH, horLineY, horLineWidthY);
            intersect check_int2(playNote2[g], NOTE_POS2[g], NOTE_WIDTH, horLineY, horLineWidthY);
            intersect check_int3(playNote3[g], NOTE_POS3[g], NOTE_WIDTH, horLineY, horLineWidthY);
            intersect check_int4(playNote4[g], NOTE_POS4[g], NOTE_WIDTH, horLineY, horLineWidthY);
        end
    endgenerate
    
    wire note1sig, note2sig, note3sig, note4sig;
    assign note1sig =|playNote1;
    assign note2sig =|playNote2;
    assign note3sig =|playNote3;
    assign note4sig =|playNote4;
    
    assign debug1 = note1sig;
    assign debug2 = note2sig;
    assign debug3 = note3sig;
    // assign debug4 = note4sig;
    
    wire color1, color2, color3, color4;

	assign color1 =|inNote1; // reduction operator OR
	assign color2 =|inNote2;
	assign color3 =|inNote3;
	assign color4 =|inNote4;
	
	wire [31:0] game_score;
	wire [3:0] intersections;
	assign intersections = {note4sig, note3sig, note2sig, note1sig};
    // if no notes are on screen, don't let strum happen
	wire inStrum = (note4sig | note3sig | note2sig | note1sig) ? (~strum) : 1'b0;
    Wrapper proc(procclk, reset, screen_clock, buttons, intersections, inStrum, game_score);
    
    assign debug4 = inStrum;
    
	wire [7:0] cat_out;
	wire [7:0] an_out;
    
    seven_segment score_display(led_clock, reset, game_score, speed, level, cat_out, an_out);
    
    assign cathode = cat_out;
    assign anode = an_out;
    
    assign buttonsHigh = 4'b1111;


    wire [11:0] felixColor;
    assign felixColor = color1 ? 12'b111100000000 : ( color2 ? 12'b000011110000 : ( color3 ? 12'b000000001111 : ( color4 ? 12'b101010101010 : ( horLine ? 12'b111111110000 : colorData))));

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	assign colorOut = active ? felixColor : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule