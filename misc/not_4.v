module not_4(result, in);
	input[3:0] in;
	output[3:0] result;

	not_2 first(result[1:0], in[1:0]);
	not_2 second(result[3:2], in[3:2]);

endmodule