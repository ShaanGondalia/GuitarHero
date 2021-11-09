module stall(fd_ir, dx_ir, xm_ir, stall, mul_stall);
	input [31:0] fd_ir, dx_ir, xm_ir;
	input mul_stall;
	output stall;

	wire [4:0] fd_op = fd_ir[31:27];
	wire [4:0] dx_op = dx_ir[31:27];
	wire [4:0] xm_op = xm_ir[31:27];

	wire fd_sw = (~fd_op[4] & ~fd_op[3] & fd_op[2] & fd_op[1] & fd_op[0]);
	wire dx_lw = (~dx_op[4] & dx_op[3] & ~dx_op[2] & ~dx_op[1] & ~dx_op[0]);

	//Stall if:
		// dx_ir is lw
		// fd rs == dx rd OR fd rt == dx rd and fd_ir is not sw
		// fd rs = fd_ir[21:17] if rtype or itype
		// dx rd = dx_ir[26:22]
		// fd rt = fd_ir[16:12] if rtype

	wire [4:0] fd_rs = fd_ir[21:17];
	wire [4:0] fd_rt = fd_ir[16:12];
	wire [4:0] dx_rd = dx_ir[26:22];

	assign stall = mul_stall | (dx_lw & ((fd_rs == dx_rd) | (fd_rt == dx_rd & ~fd_sw)));

endmodule
