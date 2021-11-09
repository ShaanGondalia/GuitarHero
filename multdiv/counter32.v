module counter32(out0, out1, out2, out3, out4, clk, clr);
	input clk, clr;
	output out4, out3, out2, out1, out0;

	tffe_ref q0(.q(out0), .t(1'b1), .clk(clk), .en(1'b1), .clr(clr));
	tffe_ref q1(.q(out1), .t(out0), .clk(clk), .en(1'b1), .clr(clr));
	tffe_ref q2(.q(out2), .t(out0 & out1), .clk(clk), .en(1'b1), .clr(clr));
	tffe_ref q3(.q(out3), .t(out0 & out1 & out2), .clk(clk), .en(1'b1), .clr(clr));
	tffe_ref q4(.q(out4), .t(out0 & out1 & out2 & out3), .clk(clk), .en(1'b1), .clr(clr));

endmodule