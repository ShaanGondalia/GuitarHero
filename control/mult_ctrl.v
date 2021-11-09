module mult_ctrl(dx_ir, mul_ir, ready, mul, div, stall, clk);
	input [31:0] dx_ir, mul_ir;

	input ready, clk;
	output mul, div, stall;

	wire old_mul, old_div;

	wire [4:0] dx_op = dx_ir[31:27];
	wire [4:0] dx_alu_op = dx_ir[6:2];

	wire [4:0] mul_op = mul_ir[31:27];
	wire [4:0] mul_alu_op = mul_ir[6:2];

	wire dx_rtype = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_mul = dx_rtype & (~dx_alu_op[4] & ~dx_alu_op[3] & dx_alu_op[2] & dx_alu_op[1] & ~dx_alu_op[0]);
	wire dx_div = dx_rtype & (~dx_alu_op[4] & ~dx_alu_op[3] & dx_alu_op[2] & dx_alu_op[1] & dx_alu_op[0]);

	wire mul_rtype = (~mul_op[4] & ~mul_op[3] & ~mul_op[2] & ~mul_op[1] & ~mul_op[0]);
	wire mul_mul = mul_rtype & (~mul_alu_op[4] & ~mul_alu_op[3] & mul_alu_op[2] & mul_alu_op[1] & ~mul_alu_op[0]);
	wire mul_div = mul_rtype & (~mul_alu_op[4] & ~mul_alu_op[3] & mul_alu_op[2] & mul_alu_op[1] & mul_alu_op[0]);

	// If instruction is mult, mul=1 div=0
	// If instruction is div, mul=0 div=1

	assign mul = dx_mul;
	assign div = dx_div;

	// If not ready, and mul or div currently happening, stall.
	dffe_neg m(.q(old_mul), .d(mul), .clk(clk), .en(mul), .clr(ready));
	dffe_neg d(.q(old_div), .d(div), .clk(clk), .en(div), .clr(ready));

	assign stall = ((dx_mul | dx_div | old_mul | old_div) & ~ready);

endmodule