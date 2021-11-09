module tffe_ref(q, t, clk, en, clr);
   
	//Inputs
	input t, clk, en, clr;

	//Output
    output q;

	dffe_neg dff(.q(q), .d(t ^ q), .clk(clk), .en(en), .clr(clr));

endmodule