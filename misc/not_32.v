module not_32(result, in);
	input[31:0] in;
	output[31:0] result;

	not_8 first(result[7:0], in[7:0]);
	not_8 second(result[15:8], in[15:8]);
	not_8 third(result[23:16], in[23:16]);
	not_8 fourth(result[31:24], in[31:24]);

endmodule