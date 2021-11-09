module or_32(result, in);
	input[31:0] in;
	output result;
	wire w1, w2, w3, w4;

	or_8 first(w1, in[7:0]);
	or_8 second(w2, in[15:8]);
	or_8 third(w3, in[23:16]);
	or_8 fourth(w4, in[31:24]);
	or(result, w1, w2, w3, w4);
endmodule