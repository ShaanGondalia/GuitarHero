module or_4(result, in);
	input[3:0] in;
	output result;
	wire w1, w2;

	or_2 first(w1, in[1:0]);
	or_2 second(w2, in[3:2]);
	or(result, w1, w2);
endmodule