module not_2(result, in);
	input[1:0] in;
	output[1:0] result;

	not(result[0], in[0]);
	not(result[1], in[1]);

endmodule