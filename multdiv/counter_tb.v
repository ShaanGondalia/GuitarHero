`timescale 1 ns / 100 ps
module counter_tb;
	reg clk, clr;
	wire [3:0] out;

	counter16 counter(out[0], out[1], out[2], out[3], clk, clr);
	
	initial begin
		$dumpfile("counter.vcd");
		$dumpvars(0, counter_tb);
	end

	integer i;
	initial begin
		clk = 1'b0;
		clr = 1'b0;
		for(i = 0; i < 100; i = i + 1) begin
			clk = ~clk;
			#20;
			$display("count: ", out);
			clk = ~clk;
		end

		$finish;
	end
endmodule
