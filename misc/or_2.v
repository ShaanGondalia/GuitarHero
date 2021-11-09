module or_2(result, in);
	input[1:0] in;
	output result;

	or(result, in[0], in[1]);
endmodule