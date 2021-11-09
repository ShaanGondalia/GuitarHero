module or_8(result, in);
	input[7:0] in;
	output result;
	wire w1, w2;

	or_4 first(w1, in[3:0]);
	or_4 second(w2, in[7:4]);
	or(result, w1, w2);
endmodule