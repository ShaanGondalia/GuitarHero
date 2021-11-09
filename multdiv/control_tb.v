`timescale 1 ns / 100 ps
module control_tb;
	reg clk, clr;
	wire [2:0] in;
	wire [3:0] count;
	wire aos, sm, nop, done;

	control ctrl(in, aos, sm, nop, done, clr, clk, count);
	
	initial begin
		$dumpfile("control.vcd");
		$dumpvars(0, control_tb);
	end

	integer i;
	assign {in} = i[2:0];
	initial begin
		clk = 1'b0;
		clr = 1'b0;
		for(i = 0; i < 100; i = i + 1) begin
			clk = ~clk;
			#20;
			$display("cycle: %d, in: %d, aos: %d, sm: %d, nop: %d, done: %d, ", i, in, aos, sm, nop, done);
			clk = ~clk;
		end

		$finish;
	end
endmodule
