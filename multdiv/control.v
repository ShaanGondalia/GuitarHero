module control(in, aos, sm, nop, done, clr, clk, count);

	input [2:0] in;
	input clr, clk;

	output aos, sm, nop, done;

	output [3:0] count;

	// CONTROL IO
		// input last 3 bits
		// output whether to shift multiplicand
		// output whether to add or subtract multiplicand
		// shift prod/multiplier by 2 *

	// Will use modified Booth's Alg
	    /*
	    – 000:middleofrunof0s,donothing
		– 100:beginningofrunof1s,subtractmultiplicand<<1(M*2)
		– 010:singleton1,addmultiplicand
		– 110:beginningofrunof1s,subtractmultiplicand
		– 001:endofrunof1s,addmultiplicand
		– 101:endofrunof1s,beginningofanother,subtractmultiplicand
		– 011:endofarunof1s,addmultiplicand<<1(M*2)
		– 111:middleofrunof1s,donothing
		*/

	//shift comes from control, either 100 or  011

	assign sm = (in[2] & ~in[1] & ~in[0]) | ( ~in[2] & in[1] & in[0]);
	assign aos = (in[2] & ~in[1] & ~in[0]) | (in[2] & ~in[1] & in[0]) | (in[2] & in[1] & ~in[0]);
	assign nop = (in[2] & in[1] & in[0]) | (~in[2] & ~in[1] & ~in[0]);

	//mux_8 shift(.out(sm), .select(in), 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0);
	//mux_8 add_sub(.out(aos), .select(in), 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);
	//mux_8 no_op(.out(noop), .select(in), 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);

	counter16 counter(count[0], count[1], count[2], count[3], clk, clr);

	assign done = &count;

endmodule