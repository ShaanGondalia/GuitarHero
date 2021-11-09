module register_neg (clock, input_enable, output_enable, clear, data, data_out);

	input clock, input_enable, output_enable, clear;
	input [31:0] data;

	output [31:0] data_out;


	genvar i;
	generate
		for (i = 0; i <= 31; i = i + 1) begin: loop1
			dffe_neg dff(.q(data_out[i]), .d(data[i]), .clk(clock), .en(input_enable), .clr(clear));
		end
	endgenerate

endmodule
