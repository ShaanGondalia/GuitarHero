module sr_latch(S, R, Q, Qnot, en);

	input S, R, en;
	output Q, Qnot;

	wire w1, w2;

	assign w1 = R & en;
	assign w2 = S & en;
	assign Q = w1 ~| Qnot;
	assign Qnot = w2 ~| Q;

endmodule
