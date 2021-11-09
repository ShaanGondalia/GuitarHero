module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire clr;

    wire [31:0] div_result, mult_result, latched_A, latched_B;
    wire mult_ready, div_ready, mult_exception, div_exception, mult_op, div_op;

    // Need to latch operands a and b
    register latchedA(.clock(clock), .input_enable(ctrl_MULT | ctrl_DIV), .output_enable(1'b1), 
        .clear(), .data(data_operandA), .data_out(latched_A));
    register latchedB(.clock(clock), .input_enable(ctrl_MULT | ctrl_DIV), .output_enable(1'b1), 
        .clear(), .data(data_operandB), .data_out(latched_B));

    mult m(.data_operandA(latched_A), .data_operandB(latched_B), .clock(clock), 
		.data_result(mult_result), .data_exception(mult_exception), .data_resultRDY(mult_ready), .clr(ctrl_MULT | ctrl_DIV));

    div d(.data_operandA(latched_A), .data_operandB(latched_B), .clock(clock), 
		.data_result(div_result), .data_exception(div_exception), .data_resultRDY(div_ready), .clr(ctrl_MULT | ctrl_DIV));

    sr_latch latch_mult(.S(ctrl_MULT), .R(ctrl_DIV), .Q(mult_op), .Qnot(), .en(clock));
    sr_latch latch_div(.S(ctrl_DIV), .R(ctrl_MULT), .Q(div_op), .Qnot(), .en(clock));

    assign data_result = mult_op ? mult_result : 32'bz;
    assign data_result = div_op ? div_result : 32'bz;
    assign data_resultRDY = mult_op ? mult_ready : 1'bz;
    assign data_resultRDY = div_op ? div_ready : 1'bz;
    assign data_exception = mult_op ? mult_exception : 1'bz;
    assign data_exception = div_op ? div_exception : 1'bz;

endmodule