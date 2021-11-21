module bypass(dx_ir, xm_ir, mw_ir, alu_in_a, alu_in_b, dmem_in);
	input [31:0] dx_ir, xm_ir, mw_ir;
	output [1:0] alu_in_a, alu_in_b; // 0 if no bypass, 1 if mx, 2 if wx.
	output dmem_in;

	wire [4:0] dx_rs, dx_rt, xm_rd, mw_rd;

	wire [4:0] dx_op = dx_ir[31:27];
	wire [4:0] xm_op = xm_ir[31:27];
	wire [4:0] mw_op = mw_ir[31:27];

	wire dx_rtype = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_addi = (~dx_op[4] & ~dx_op[3] & dx_op[2] & ~dx_op[1] & dx_op[0]);
	wire dx_lw = (~dx_op[4] & dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_sw = (~dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & dx_op[0]);
	wire dx_bne = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & dx_op[1] & ~dx_op[0]);
	wire dx_blt = (~dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & ~dx_op[0]);
	wire dx_itype_nonbranch = dx_addi | dx_lw | dx_sw;
	wire dx_itype_branch = dx_bne | dx_blt;
	wire dx_jr = (~dx_op[4] & ~dx_op[3] & dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_bex = (dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & ~dx_op[0]);

	wire xm_sw = (~xm_op[4] & ~xm_op[3] & xm_op[2] & xm_op[1] & xm_op[0]);
	wire xm_bne = (~xm_op[4] & ~xm_op[3] & ~xm_op[2] & xm_op[1] & ~xm_op[0]);
	wire xm_blt = (~xm_op[4] & ~xm_op[3] & xm_op[2] & xm_op[1] & ~xm_op[0]);

	wire mw_sw = (~mw_op[4] & ~mw_op[3] & mw_op[2] & mw_op[1] & mw_op[0]);
	wire mw_lw = (~mw_op[4] & mw_op[3] & ~mw_op[2] & ~mw_op[1] & ~mw_op[0]);
	wire mw_bne = (~mw_op[4] & ~mw_op[3] & ~mw_op[2] & mw_op[1] & ~mw_op[0]);
	wire mw_blt = (~mw_op[4] & ~mw_op[3] & mw_op[2] & mw_op[1] & ~mw_op[0]);

	// WX and MX Bypassing for aluA
	// If dx ir needs updated register value from previous instruction
	// => rd of xm == rs or rt of dx
	// rd of xm = xm_ir[26:22]
	// rs of dx = dx_ir [21:17] if r or i type non branch.
	// rs of dx = dx_ir[26:22] if i type branch
	// if wx or mx is sw, blt, or bne, then dont bypass
	// Remember that rd of bex is hardcoded to r30. If this matches rd of mw or xm, then we need to bypass
	assign mw_rd = mw_ir[26:22];
	assign xm_rd = xm_ir[26:22];
	assign dx_rs = (dx_rtype | dx_itype_nonbranch) ? dx_ir[21:17] : 5'bz;
	assign dx_rs = (dx_itype_branch) ? dx_ir[26:22] : 5'bz;

	assign dx_rs = dx_jr ? dx_ir[26:22] : 5'bz;
	assign dx_rs = dx_bex ? 5'b11110 : 5'bz;
	assign dx_rs = ~(dx_jr | dx_bex | dx_itype_branch | dx_rtype | dx_itype_nonbranch) ? 5'b0 : 5'bz;

	assign alu_in_a[0] = (xm_rd == dx_rs & ~(xm_sw | xm_bne | xm_blt) & (xm_rd != 5'b0));
	assign alu_in_a[1] = mw_rd == dx_rs & ~(mw_sw | mw_bne | mw_blt) & (mw_rd != 5'b0) & ~alu_in_a[0];

	// WX and MX Bypassing for aluB
	// => rd of xm or mw = rt of dx rtype or rd of bne, blt
	// rt of dx = dx_ir[16:12] if r type.
	// rd of bne, blt = dx_ir[26:22]
	assign dx_rt = (dx_rtype) ? dx_ir[16:12] : 5'bz;
	assign dx_rt = (dx_itype_nonbranch) ? dx_ir[26:22] : 5'bz;
	assign dx_rt = (dx_itype_branch) ? dx_ir[21:17] : 5'bz;
	assign dx_rt = ~(dx_itype_branch | dx_itype_nonbranch | dx_rtype) ? 5'b0 : 5'bz;

	assign alu_in_b[0] = (xm_rd == dx_rt & ~(xm_sw | xm_bne | xm_blt) & (xm_rd != 5'b0));
	assign alu_in_b[1] = mw_rd == dx_rt & ~(mw_sw | mw_bne | mw_blt) & (mw_rd != 5'b0) & ~alu_in_b[0];

	//WM Bypassing
	// Load then immediately store is a problem
	// mw is load and xm is store, mw rd is xm rd 
	// => mw rd is sw rd 
	assign dmem_in = (xm_sw & mw_lw & (mw_rd == xm_rd)) ? 1'b1 : 1'b0;


endmodule

