/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB,                  // I: Data from port B of RegFile

    //Guitar Hero Inputs
    buttons,
    intersections,
    strum,
    gameclk,
    score
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    // Guitar Hero
    input [3:0] buttons;
    input [3:0] intersections;
    input strum;
    input gameclk;
    output [31:0] score;

    // Reg wires
    wire [31:0] pci, pco; // PC out and in
    wire [31:0] fd_pci, fd_pco, fd_ir, fd_ir_in; // fd reg wires
    wire [31:0] dx_pco, dx_ir_in, dx_ir, dx_a, dx_b; // dx reg wires
    wire [31:0] xm_ir_i, overflow_ir, xm_ir, xm_o, xm_b, mul_ir, mul_p, xm_pco, xm_o_i; // xm reg wires
    wire [31:0] mw_ir, mw_o, mw_d, mw_pco; // mw reg wires

    // Stage wires
    wire [31:0] pc_inc; // F stage wires
    wire [31:0] alu_a, alu_b, bypass_a, bypass_b, pcx_res, alu_result, mult_res, im_in_alu_b; // X stage wires
    wire ne, lt, overflow; // X stage wires
    wire mul_ctrl_div, mul_ctrl_mul, mul_stall, mul_ready; // Mul stage wires
    wire [31:0] wb_data; // W stage wires

    // Datapath wires
    wire dp_branch; // F stage datapath control wires
    wire dp_reg_we; // D stage datapath wires
    wire [4:0] dp_reg_a, dp_reg_b, dp_wreg; // D stage datapath wires
    wire [31:0] dp_immediate, cla_in_a, cla_in_b; // X stage datapath wires
    wire dp_im_en, dp_jbranch, dp_jr_im, dp_setx, dp_bex; // X stage datapath wires
    wire [4:0] dp_alu_op; // X stage datapath wires
    wire dp_mwren; // M stage datapath wires
    wire [1:0] dp_wb; // W stage datapath wires

    // Bypass wires
    wire [1:0] bypass_alu_a, bypass_alu_b;
    wire bypass_dmem_in;

    // Stall wires
    wire stall_ctrl;

    // Datapath control
    datapath dp_ctrl(.fd_ir(fd_ir), .dx_ir(dx_ir), .xm_ir(xm_ir), .mw_ir(mw_ir), .mul_ir(mul_ir), 
        .reg_we(dp_reg_we), .ne(ne), .lt(lt),
        .reg_a(dp_reg_a), .reg_b(dp_reg_b), .wreg(dp_wreg), .im(dp_immediate),
        .im_en(dp_im_en), .alu_op(dp_alu_op), .mwren(dp_mwren), .wb(dp_wb), .branch(dp_branch),
        .mul_rdy(mul_ready), .jbranch(dp_jbranch), .jr_im(dp_jr_im), .setx(dp_setx), .bex(dp_bex));

    // Bypass control
    bypass bp_ctrl(.dx_ir(dx_ir), .xm_ir(xm_ir), .mw_ir(mw_ir), 
        .alu_in_a(bypass_alu_a), .alu_in_b(bypass_alu_b), .dmem_in(bypass_dmem_in));

    // Stall control
    stall s_ctrl(.fd_ir(fd_ir), .dx_ir(dx_ir), .xm_ir(xm_ir), .stall(stall_ctrl), .mul_stall(mul_stall));

    // PC Reg
    register_neg pc_reg(.clock(clock), .input_enable(~stall_ctrl & ~w0 & ~w1), .output_enable(1'b1), 
        .clear(reset), .data(fd_pci), .data_out(pco));

    // Guitar Hero Hardware
    wire old_strum, new_strum, guitar_update, guitar_inc, guitar_score;
    guitar guitar_ctrl(.mw_ir(mw_ir), .old_strum(old_strum), .new_strum(new_strum), 
        .buttons(buttons), .intersections(intersections), 
        .update(guitar_update), .inc(guitar_inc), .score_out(guitar_score));

    dffe_neg new_s(.q(new_strum), .d(strum), .clk(gameclk), .en(1'b1), .clr(reset));
    dffe_neg old_s(.q(old_strum), .d(new_strum), .clk(clock), .en(1'b1), .clr(reset));

    // Mux in 2 commands and stall PC 2 cycles depending on update and inc
    // Update reg: 32'b00101000010000000000000000000001
    // Inc: 32'b00101000100000000000000000000010
    // Dec: 32'b00101000100000000000000000000000

    wire inc;
    assign inc_or_dec_ir = inc ? 32'b00101000100000000000000000000010 : 32'b00101000100000000000000000000000;
    wire [31:0] guitar_fd_ir, inc_or_dec_ir;
    mux_4 guitar_inst(.out(guitar_fd_ir), .select({w1, w0}), 
        .in0(fd_ir_in), // Normal Code
        .in1(inc_or_dec_ir), // INC
        .in2(32'b00101000010000000000000000000001), // Update Reg
        .in3(32'b0));

    // FSM for stalls

    wire out2, out1, out0;
    wire in0 = (~out2 & ~out1 & ~out0 & guitar_update) | (~out2 & out1 & ~out0) | (out2 & ~out1 & ~out0);
    wire in1 = (~out2 & ~out1 & out0) | (~out2 & out1 & ~out0);
    wire in2 = (out2 & ~out1 & ~out0) | (~out2 & out1 & out0);
    wire w1 = out2 | out1;
    wire w0 = (~out2 & out0) | out2;

    dffe_neg y0(.q(out0), .d(in0), .clk(clock), .en(1'b1), .clr(reset));
    dffe_neg y1(.q(out1), .d(in1), .clk(clock), .en(1'b1), .clr(reset));
    dffe_neg y2(.q(out2), .d(in2), .clk(clock), .en(1'b1), .clr(reset));
    dffe_neg iord(.q(inc), .d(guitar_inc), .clk(clock), .en(1'b1), .clr(reset));


    // Fetch Stage
    assign address_imem = pco;
    cla_32 pc_incrementor(.A(pco), .B({31'b0, 1'b1}), .Cin(1'b0),
               .S(pc_inc), .Cout(), .And(), .Or());
    assign fd_pci = dp_branch ? pcx_res : pc_inc;

    assign fd_ir_in = dp_branch ? 32'b0 : q_imem;

    // F/D Regs
    register_neg fd_pc_reg(.clock(clock), .input_enable(~stall_ctrl & ~w0 & ~w1), .output_enable(1'b1), 
        .clear(reset), .data(fd_pci), .data_out(fd_pco));
    register_neg fd_ir_reg(.clock(clock), .input_enable(~stall_ctrl), .output_enable(1'b1), 
        .clear(reset), .data(guitar_fd_ir), .data_out(fd_ir));

    // Decode Stage
    assign ctrl_writeReg = dp_wreg;
    assign ctrl_writeEnable = dp_reg_we;
    assign ctrl_readRegA = dp_reg_a;
    assign ctrl_readRegB = dp_reg_b;
    assign data_writeReg = wb_data;

    assign dx_ir_in = stall_ctrl | dp_branch ? 32'b0 : fd_ir; 

    // D/X Regs
    register_neg dx_pc_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(fd_pco), .data_out(dx_pco));
    register_neg dx_ir_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(dx_ir_in), .data_out(dx_ir));
    register_neg dx_a_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(data_readRegA), .data_out(dx_a));
    register_neg dx_b_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(data_readRegB), .data_out(dx_b));

    // Execute Stage
    mux_4 alu_a_bypass(.out(bypass_a), .select(bypass_alu_a), .in0(dx_a), .in1(xm_o), .in2(wb_data), .in3());
    mux_4 alu_b_bypass(.out(bypass_b), .select(bypass_alu_b), .in0(dx_b), .in1(xm_o), .in2(wb_data), .in3());

    assign im_in_alu_b = dp_bex ? 32'b0 : dp_immediate;

    assign alu_a = dp_setx ? 32'b0 : bypass_a;
    assign alu_b = dp_im_en ? im_in_alu_b : bypass_b;

    assign cla_in_a = dp_jbranch | dp_bex ? 32'b0 : dx_pco;
    assign cla_in_b = dp_jr_im ? bypass_a : dp_immediate;

    cla_32 pcx_cla(.A(cla_in_a), .B(cla_in_b), .Cin(1'b0),
               .S(pcx_res), .Cout(), .And(), .Or());

    alu x_alu(.data_operandA(alu_a), .data_operandB(alu_b), 
        .ctrl_ALUopcode(dp_alu_op), .ctrl_shiftamt(dx_ir[11:7]),
        .data_result(alu_result), .isNotEqual(ne), .isLessThan(lt), .overflow(overflow));

    multdiv X(.data_operandA(bypass_a), .data_operandB(bypass_b), 
        .ctrl_MULT(mul_ctrl_mul), .ctrl_DIV(mul_ctrl_div), .clock(clock), 
        .data_result(mult_res), .data_exception(), .data_resultRDY(mul_ready));

    mult_ctrl mul(.dx_ir(dx_ir), .ready(mul_ready), 
        .mul(mul_ctrl_mul), .div(mul_ctrl_div), .stall(mul_stall), .clk(clock));

    // If overflow, change instruction to addi
    assign overflow_ir[31:27] = 5'b0;
    assign overflow_ir[26:22] = 5'b11110;
    assign overflow_ir[21:0] = 22'b0;
    assign xm_ir_i = (overflow | dp_setx) ? overflow_ir : dx_ir;
    assign xm_o_i = overflow ? 32'b1 : alu_result;

    // X/M Regs
    register_neg xm_pc_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(dx_pco), .data_out(xm_pco));
    register_neg xm_ir_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(xm_ir_i), .data_out(xm_ir));
    register_neg xm_o_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(xm_o_i), .data_out(xm_o));
    register_neg xm_b_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(bypass_b), .data_out(xm_b));

    register_neg mul_ir_reg(.clock(clock), .input_enable(mul_ctrl_mul | mul_ctrl_div), .output_enable(1'b1), 
        .clear(reset), .data(dx_ir), .data_out(mul_ir));

    // Memory Stage
    assign address_dmem = xm_o;
    assign data = bypass_dmem_in ? wb_data : xm_b;
    assign wren = dp_mwren;

    // M/W Reg
    register_neg mw_pc_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(xm_pco), .data_out(mw_pco));
    register_neg mw_ir_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(xm_ir), .data_out(mw_ir));
    register_neg mw_o_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(xm_o), .data_out(mw_o));
    register_neg mw_d_reg(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
        .clear(reset), .data(q_dmem), .data_out(mw_d));

    // Writeback Stage
    mux_4 writeback(.out(wb_data), .select(dp_wb), .in0(mw_o), .in1(mw_d), .in2(mult_res), .in3(mw_pco));
    assign score = guitar_score ? wb_data : 32'b1;

endmodule
