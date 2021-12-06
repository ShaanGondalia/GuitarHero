`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2021 04:41:47 PM
// Design Name: 
// Module Name: debounce
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


module debounce(
    input clk, // 100 MHz
    input bouncy_value, // assume bouncy value is high when pressed
    output good);
    
    // how long to keep it high
    reg[26:0] high_counter = 0;
    reg[26:0] high_limit = 833332;
    
    reg[26:0] debounce_counter = 0;
    reg[26:0] debounce_limit = 10000000;
    reg value = 0;
    
    always @(posedge clk) begin
        if(bouncy_value) begin
	   	   debounce_counter = debounce_counter + 1;
	    end else begin
	       debounce_counter = 0;
	       value = 0;
	   	end
	   	
	   	if(debounce_counter >= debounce_limit) begin
	   	   debounce_counter = 0;
	   	   value = 1;
	   	end
	   	
	   	if(value) begin
	   	   high_counter = high_counter + 1;
	   	end else begin
	   	   high_counter = 0;
	   	end
	   	
	   	if(value && high_counter >= high_limit) begin
	   	   value = 0;
	   	   high_counter = 0;
	   	end
    end
    
    assign good = value;
    
endmodule