module not_8(result, in);
	input[7:0] in;
	output[7:0] result;

	not_4 first(result[3:0], in[3:0]);
	not_4 second(result[7:4], in[7:4]);

endmodule