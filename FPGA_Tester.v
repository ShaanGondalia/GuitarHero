`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2021 06:51:18 PM
// Design Name: 
// Module Name: FPGA_Tester
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


module FPGA_Tester(clk, reset, buttons, intersections, strum, lower_score, high_buttons, button_out);
    input clk;
    input reset;
    input [3:0] buttons;
    input [3:0] intersections;
    input strum;
    
    output [7:0] lower_score;
    output [3:0] high_buttons;
    output [3:0] button_out;
    
    wire [31:0] procscore;
    
    assign button_out = buttons;
    assign high_buttons = 4'b1111;
    
    Wrapper w(.clock(procclk), .reset(reset), .gameclk(gameclk), 
        .buttons(buttons), 
        .intersections(intersections), 
        .strum(~strum), 
        .score(procscore));
        
    localparam MHz = 1000000;
	localparam SYSTEM_FREQ = 100*MHz; // System clock frequency
	
	// Clock divider for processor (Running at 1 Mhz)
	reg[23:0] ProcCounterLimit;
	reg procclk = 0;
	reg[23:0] proccounter = 0;
	always @(posedge clk) begin
	    ProcCounterLimit = SYSTEM_FREQ / (2*MHz - 1);
        if(proccounter < ProcCounterLimit)
	       proccounter <= proccounter + 1;
        else begin
	       proccounter <=0;
	       procclk <= ~procclk;
        end
    end
        
    // Clock divider for game clock (60 Hz)
    reg[23:0] GameCounterLimit;
	reg gameclk = 0;
	reg[23:0] gamecounter = 0;
	always @(posedge clk) begin
	    GameCounterLimit = SYSTEM_FREQ / (2*60 - 1);
        if(gamecounter < GameCounterLimit)
	       gamecounter <= gamecounter + 1;
        else begin
	       gamecounter <=0;
	       gameclk <= ~gameclk;
        end
    end
        
    assign lower_score = procscore[15:0];

endmodule
