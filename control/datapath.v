module datapath(fd_ir, dx_ir, xm_ir, mw_ir, mul_ir, ne, lt, reg_we, reg_a, reg_b, 
	wreg, im, im_en, alu_op, mwren, wb, branch, mul_rdy, jbranch, jr_im, setx, bex);

	input [31:0] fd_ir, dx_ir, xm_ir, mw_ir, mul_ir;
	input ne, lt, mul_rdy;
	output reg_we, im_en, mwren, branch, jbranch, jr_im, setx, bex;
	output [1:0] wb;
	output [4:0] reg_a, reg_b, wreg, alu_op;
	output [31:0] im;

	wire [4:0] fd_op = fd_ir[31:27];
	wire [4:0] dx_op = dx_ir[31:27];
	wire [4:0] xm_op = xm_ir[31:27];
	wire [4:0] mw_op = mw_ir[31:27];
	wire [4:0] mul_op = mul_ir[31:27];

	wire [4:0] mul_alu_op = mul_ir[6:2];

	//Assign opcodes to hardware wires
	wire fd_rtype = (~fd_op[4] & ~fd_op[3] & ~fd_op[2] & ~fd_op[1] & ~fd_op[0]);
	wire fd_addi = (~fd_op[4] & ~fd_op[3] & fd_op[2] & ~fd_op[1] & fd_op[0]);
	wire fd_lw = (~fd_op[4] & fd_op[3] & ~fd_op[2] & ~fd_op[1] & ~fd_op[0]);
	wire fd_sw = (~fd_op[4] & ~fd_op[3] & fd_op[2] & fd_op[1] & fd_op[0]);
	wire fd_bne = (~fd_op[4] & ~fd_op[3] & ~fd_op[2] & fd_op[1] & ~fd_op[0]);
	wire fd_blt = (~fd_op[4] & ~fd_op[3] & fd_op[2] & fd_op[1] & ~fd_op[0]);
	wire fd_jr = (~fd_op[4] & ~fd_op[3] & fd_op[2] & ~fd_op[1] & ~fd_op[0]);
	wire fd_setx = (fd_op[4] & ~fd_op[3] & fd_op[2] & ~fd_op[1] & fd_op[0]);
	wire fd_bex = (fd_op[4] & ~fd_op[3] & fd_op[2] & fd_op[1] & ~fd_op[0]);

	wire dx_rtype = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_addi = (~dx_op[4] & ~dx_op[3] & dx_op[2] & ~dx_op[1] & dx_op[0]);
	wire dx_lw = (~dx_op[4] & dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_sw = (~dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & dx_op[0]);
	wire dx_bne = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & dx_op[1] & ~dx_op[0]);
	wire dx_blt = (~dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & ~dx_op[0]);
	wire dx_jal = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & dx_op[1] & dx_op[0]);
	wire dx_j = (~dx_op[4] & ~dx_op[3] & ~dx_op[2] & ~dx_op[1] & dx_op[0]);
	wire dx_jr = (~dx_op[4] & ~dx_op[3] & dx_op[2] & ~dx_op[1] & ~dx_op[0]);
	wire dx_setx = (dx_op[4] & ~dx_op[3] & dx_op[2] & ~dx_op[1] & dx_op[0]);
	wire dx_bex = (dx_op[4] & ~dx_op[3] & dx_op[2] & dx_op[1] & ~dx_op[0]);

	wire xm_sw = (~xm_op[4] & ~xm_op[3] & xm_op[2] & xm_op[1] & xm_op[0]);

	wire mw_rtype = (~mw_op[4] & ~mw_op[3] & ~mw_op[2] & ~mw_op[1] & ~mw_op[0]);
	wire mw_addi = (~mw_op[4] & ~mw_op[3] & mw_op[2] & ~mw_op[1] & mw_op[0]);
	wire mw_lw = (~mw_op[4] & mw_op[3] & ~mw_op[2] & ~mw_op[1] & ~mw_op[0]);
	wire mw_jal = (~mw_op[4] & ~mw_op[3] & ~mw_op[2] & mw_op[1] & mw_op[0]);
	wire mw_setx = (mw_op[4] & ~mw_op[3] & mw_op[2] & ~mw_op[1] & mw_op[0]);

	wire mul_rtype = (~mul_op[4] & ~mul_op[3] & ~mul_op[2] & ~mul_op[1] & ~mul_op[0]);
	wire mul_mul = mul_rtype & (~mul_alu_op[4] & ~mul_alu_op[3] & mul_alu_op[2] & mul_alu_op[1] & ~mul_alu_op[0]);
	wire mul_div = mul_rtype & (~mul_alu_op[4] & ~mul_alu_op[3] & mul_alu_op[2] & mul_alu_op[1] & mul_alu_op[0]);

	wire mul_div_wb = mul_rdy & (mul_mul | mul_div);

	// D stage control
	assign reg_we = mul_div_wb | mw_rtype | mw_addi | mw_lw | mw_jal;

	assign wreg = (mw_rtype | mw_addi | mw_lw ) & ~mul_div_wb ? mw_ir[26:22] : 5'bz;
	assign wreg = mw_jal ? 5'b11111 : 5'bz;
	assign wreg = mul_div_wb ? mul_ir[26:22] : 5'bz;
	assign wreg = ~(mw_rtype | mw_addi | mw_lw | mw_jal | mul_div_wb)  ? 5'b0 : 5'bz;

	assign reg_a = (fd_rtype | fd_addi) ? fd_ir[21:17] : 5'bz;
	assign reg_a = (fd_bne | fd_blt | fd_jr) ? fd_ir[26:22] : 5'bz;
	assign reg_a = (fd_sw | fd_lw) ? fd_ir[21:17] : 5'bz;
	assign reg_a = (fd_bex) ? 5'b11110 : 5'bz;
	assign reg_a = ~(fd_rtype | fd_bne | fd_blt | fd_sw | fd_lw | fd_addi | fd_jr | fd_bex) ? 5'b0 : 5'bz;

	assign reg_b = (fd_rtype | fd_addi) ? fd_ir[16:12] : 5'bz;
	assign reg_b = (fd_bne | fd_blt) ? fd_ir[21:17] : 5'bz;
	assign reg_b = (fd_sw | fd_lw) ? fd_ir[26:22] : 5'bz;
	assign reg_b = ~(fd_rtype | fd_bne | fd_blt | fd_sw | fd_lw | fd_addi) ? 5'b0 : 5'bz;

	// X stage control
	assign im = (dx_addi | dx_lw | dx_sw | dx_bne | dx_blt) ? {{15{dx_ir[16]}}, dx_ir[16:0]} : 32'bz;
	assign im = (dx_j | dx_jal | dx_bex | dx_setx) ? {5'b0, dx_ir[26:0]} : 32'bz;
	assign im = ~(dx_addi | dx_lw | dx_sw | dx_bne | dx_blt | dx_j | dx_jal | dx_setx | dx_bex) ? 32'b0 : 32'bz;

	assign im_en = dx_addi | dx_sw | dx_lw | dx_setx |dx_bex;

	assign jr_im = dx_jr;
	assign setx = dx_setx;
	assign bex = dx_bex;

	assign alu_op = dx_rtype ? dx_ir[6:2] : 5'bz;
	assign alu_op = (dx_bne | dx_blt | dx_bex) ? {4'b0, 1'b1} : 5'bz;
	assign alu_op = ~(dx_rtype | dx_bne | dx_blt | dx_bex) ? 5'b0 : 5'bz;

	assign branch = (dx_blt & lt) | (dx_bne & ne) | dx_jal | dx_j | dx_jr | (dx_bex & ne);

	assign jbranch = dx_jal | dx_j | dx_jr;

	// M stage control
	assign mwren = xm_sw;

	// W stage control
	assign wb[0] = mw_lw | mw_jal;
	assign wb[1] = mul_div_wb | mw_jal;

endmodule