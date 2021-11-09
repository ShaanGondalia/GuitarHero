module sll_8(out, in);
	input[31:0] in;
	output[31:0] out;

	assign out[7:0] = 0;
	assign out[31:8] = in[23:0];

endmodule