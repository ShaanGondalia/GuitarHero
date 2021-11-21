`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	input move_up,
	input move_down,
	input move_right,
	input move_left,
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	);
	
	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/fj32/OneDrive - Duke University/Documents/lab5_ece350/Lab5/";

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
	integer screen_counter = 0;
	integer screen_limit = 833332; // 100 MHz -> 60 Hz need counter limit = 100 000 000 / (2 * 60) - 1

	// new notes clock: how often we check for a new note
	reg new_notes_clock = 0; // .5 Hz clock (new notes come on once every 2 seconds)
	integer new_notes_counter = 0;
	integer new_notes_limit = 49999999; // 100 MHz -> 0.5 Hz need counter limit = 100 000 000 / (2 * 0.5) - 1

	// clock divider
	always @(posedge clk) begin
		if(new_notes_counter < new_notes_limit)
	       new_notes_counter <= new_notes_counter + 1;
	   	else begin
	       new_notes_counter <= 0;
	       new_notes_clock <= ~new_notes_clock;
		end

		if(screen_counter < screen_limit)
	       screen_counter <= screen_counter + 1;
	   	else begin
	       screen_counter <= 0;
	       screen_clock <= ~screen_clock;
	   	end
	end

	reg[3:0] NOTES[0:20];
	initial begin
		$readmemh("Notes.mem", NOTES);
		// stores the notes we will load, in 4 bit code where a bit being high means that bar has a note
		// mem file uses hex it seems like
	end
	
	localparam MAX_NOTES_ON_SCREEN = 8;
	reg[9:0] NOTE_POS[0:MAX_NOTES_ON_SCREEN - 1]; // top left corner of notes

	localparam NOTE_SPEED = 1;
	reg[9:0] NOTE_1_X = 320;
	reg[6:0] NOTE_WIDTH = 50;

	integer new_notes_index = 0; // index into NOTES, only increases
	integer curr_notes_index = 0; // index into NOTE_POS, will loop back around after some note is done
	always @(posedge new_notes_clock) begin
		if(NOTES[new_notes_index][3] == 0) begin
			NOTE_POS[curr_notes_index] = VIDEO_HEIGHT; // don't want to display it
		end else begin
			NOTE_POS[curr_notes_index] = 0;
		end
		new_notes_index = new_notes_index + 1;
		curr_notes_index = (curr_notes_index + 1) % MAX_NOTES_ON_SCREEN;
	end

	// move notes
	always @(posedge screen_clock) begin
		NOTE_POS[0] = NOTE_POS[0] + NOTE_SPEED;
	end

	// top left of square x and y, and then square width
	reg[9:0] xtl = VIDEO_WIDTH / 2;
	reg[8:0] ytl = VIDEO_HEIGHT / 2;
	reg[6:0] width = 100;
	// square color is 12'b111100000000; red is f, green and blue are 0
    always @(posedge screenEnd) begin
        // ytl = move_up ? ytl - 1 : ytl;
        // ytl = move_down ? ytl + 1 : ytl;
        // xtl = move_left ? xtl - 1 : xtl;
        // xtl = move_right ? xtl + 1 : xtl;
        // if (ytl < 2)
        //     ytl = 2;
        // if (xtl < 2)
        //     xtl = 2;
        // if (ytl + width > VIDEO_HEIGHT)
        //     ytl = VIDEO_HEIGHT - width;
        // if (xtl + width > VIDEO_WIDTH)
        //     xtl = VIDEO_WIDTH - width;
    end
    
	wire inNote;
	// can genvar to check all notes in each row, since they should be the same color
    check_bounds note1(inNote, NOTE_1_X, NOTE_POS[0], NOTE_WIDTH, x, y);

    wire [11:0] felixColor;
    assign felixColor = inNote ? 12'b111100000000 : colorData;

	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	assign colorOut = active ? felixColor : 12'd0; // When not active, output black

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule