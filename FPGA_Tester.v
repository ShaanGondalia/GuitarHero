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


module FPGA_Tester(clk, reset, buttons, intersections, strum, lower_score);
    input clk;
    input reset;
    input [3:0] buttons;
    input [3:0] intersections;
    input strum;
    
    output [15:0] lower_score;
    
    wire [31:0] procscore;
    
    Wrapper w(.clock(procclk), .reset(reset), .gameclk(gameclk), 
        .buttons(buttons), 
        .intersections(intersections), 
        .strum(strum), 
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
