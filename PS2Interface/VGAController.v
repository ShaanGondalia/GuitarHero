`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz System Clock
	input reset, 		// Reset Signal
	output hSync, 		// H Sync Signal
	output vSync, 		// Veritcal Sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	inout ps2_clk,
	inout ps2_data,
	input left,
	input right,
	input up,
	input down);
	
	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/sg491/OneDrive - Duke University/Documents/Lab5/";

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
		.wEn(1'b0)); 						       // We're always reading
	
	wire[7:0] spriteAddr;
	wire spriteData;
	wire[7:0] asciiAddr;
	
	
    RAMVGA #(
		.DEPTH(4700), 		       // Set depth to contain every color		
		.DATA_WIDTH(50), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(2500),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "sprites.mem"}))
    Sprites(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(spriteAddr),					       // Address from the ImageData RAM
		.dataOut(spriteData),				       // Color at current pixel
		.wEn(1'b0));   // Memory initialization
		
    RAMVGA #(
		.DEPTH(256), 		       // Set depth to contain every color		
		.DATA_WIDTH(8), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(8),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "ascii.mem"}))
    Ascii(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(asciiAddr),					       // Address from the ImageData RAM
		.dataOut(spriteAddr),				       // Color at current pixel
		.wEn(1'b0));   // Memory initialization
		
	Ps2Interface interface(
	   .ps2_clk(ps2_clk),
	   .ps2_data(ps2_data),
	   .clk(ps2_clk),
	   .rst(1'b0),
	   .tx_data(),
	   .write_data(),
	   .rx_data(asciiAddr),
	   .read_data(),
	   .busy(),
	   .err()
	);	

	// Square
	reg[9:0] ref_x = 0;
	reg[8:0] ref_y = 0;
	
	wire[BITS_PER_COLOR-1:0] new_data;
    wire square;
    
	assign square = (x>ref_x) & (x < ref_x + 50) & (y>ref_y) & (y < ref_y + 50);
	assign new_data = square ? spriteData : colorData;
	
	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut; 			  // Output color 
	assign colorOut = active ? new_data : 12'd0; // When not active, output black
	
    always @(posedge screenEnd) begin
		ref_x = left ? ref_x-1 : ref_x;
		ref_x = right ? ref_x+1 : ref_x;
		ref_y = down ? ref_y+1 : ref_y;
		ref_y = up ? ref_y-1 : ref_y;
		
		if(ref_x<1) begin
		  ref_x = 1;
		end
		if(ref_y<1) begin
		  ref_y = 1;
		end
		if(ref_x>590) begin
		  ref_x = 590;
		end
		if(ref_y>430) begin
		  ref_y = 430;
		end
	end

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule