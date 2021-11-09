module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	//wire [31:0] r [31:0];
	wire [31:0] ie;
	wire [31:0] oea;
	wire [31:0] oeb;

	// Decode write enable / read enable here. Need 5 to 32 decoder
	decoder write_decoder(.select(ctrl_writeReg), .enable(1'b1), .out(ie));
	decoder read_a_decoder(.select(ctrl_readRegA), .enable(1'b1), .out(oea));
	decoder read_b_decoder(.select(ctrl_readRegB), .enable(1'b1), .out(oeb));

	// Zero register
	tri_buffer a_tri(.in(32'b0), .out(data_readRegA), .oe(oea[0]));
	tri_buffer b_tri(.in(32'b0), .out(data_readRegB), .oe(oeb[0]));

	genvar i;
	generate
		for (i = 1; i <= 31; i = i + 1) begin: loop1
			wire [31:0] out;
			wire write_enable;

			and we(write_enable, ie[i], ctrl_writeEnable);

			register a_reg(.clock(clock), .input_enable(write_enable), .output_enable(1'b1),
				.clear(ctrl_reset), .data(data_writeReg), .data_out(out));

			tri_buffer a_tri(.in(out), .out(data_readRegA), .oe(oea[i]));
			tri_buffer b_tri(.in(out), .out(data_readRegB), .oe(oeb[i]));

		end
	endgenerate

endmodule
