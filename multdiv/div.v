module div(
	data_operandA, data_operandB, 
	clock, 
	data_result, data_exception, data_resultRDY, clr);

    input [31:0] data_operandA, data_operandB;
    input clock, clr;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] upper_quot, lower_quot, final;
    wire [31:0] dividend, divisor, negated_dividend, negated_divisor;
    wire subtract, nop, shift;

    wire [31:0] cla_result, step_result, shifted_upper, shifted_lower, new_lower, new_upper, negated_new_lower;

    wire [31:0] w2, w3;
    wire sign, overflow1, overflow2, e;
    wire [4:0] count;
    wire neg_result;

    counter32 c(count[0], count[1], count[2], count[3], count[4], clock, clr);

    // e is 0 if counter is 0, 1 otherwise
    assign e = (count[0] | count[1] | count[2] | count[3] | count[4]);
    assign neg_result = data_operandA[31] ^ data_operandB[31];

    assign dividend = data_operandA[31] ? negated_dividend : data_operandA;
    assign divisor = data_operandB[31] ? negated_divisor : data_operandB; 

    alu negator_dividend(.data_operandA(32'b0), .data_operandB(data_operandA), 
        .ctrl_ALUopcode({4'b0, 1'b1}), .ctrl_shiftamt(5'b0),
        .data_result(negated_dividend), .isNotEqual(), .isLessThan(), .overflow());

    alu negator_divisor(.data_operandA(32'b0), .data_operandB(data_operandB), 
        .ctrl_ALUopcode({4'b0, 1'b1}), .ctrl_shiftamt(5'b0),
        .data_result(negated_divisor), .isNotEqual(), .isLessThan(), .overflow());

    // Registers for first/second half of products and extra bit
    register upper_quotient(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
    	.clear(clr), .data(new_upper), .data_out(w3));

    register lower_quotient(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
    	.clear(clr), .data(new_lower), .data_out(w2));

    // Assigning starting values if counter started at 0
    assign lower_quot = e ? w2 : dividend;
    assign upper_quot = e ? w3 : 32'b0;

    // Check sign bit of A
    assign sign = shifted_upper[31];
    assign subtract = ~sign;

    // Leftshift AQ
    assign shifted_lower = lower_quot <<< 1;
    assign shifted_upper[31:1] = upper_quot[30:0];
    assign shifted_upper[0] = lower_quot[31];

    // ALU operation, add or subtract shifted or nonshifted
    wire [4:0] opcode = {4'b0, subtract};
    alu step_adder(.data_operandA(shifted_upper), .data_operandB(divisor), 
        .ctrl_ALUopcode(opcode), .ctrl_shiftamt(5'b0),
        .data_result(cla_result), .isNotEqual(), .isLessThan(), .overflow());

    assign new_lower[31:1] = shifted_lower[31:1]; 
    assign new_lower[0] = ~new_upper[31];
    assign new_upper = cla_result;

    assign final = neg_result ? negated_new_lower : new_lower;

    assign data_result = data_exception ? 32'b0 : final;

    assign data_exception = ~(|divisor);
    assign data_resultRDY = &count;

    alu negator_result(.data_operandA(32'b0), .data_operandB(new_lower), 
        .ctrl_ALUopcode({4'b0, 1'b1}), .ctrl_shiftamt(5'b0),
        .data_result(negated_new_lower), .isNotEqual(), .isLessThan(), .overflow());

endmodule