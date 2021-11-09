module mult(
	data_operandA, data_operandB, 
	clock, 
	data_result, data_exception, data_resultRDY, clr);

    input signed [31:0] data_operandA, data_operandB;
    input clock, clr;

    output signed [31:0] data_result;
    output data_exception, data_resultRDY;

    wire signed [31:0] upper_prod, lower_prod;
    wire signed [31:0] multiplicand, multiplicand_after_shift;
    wire subtract, nop, shift;

    wire [3:0] count;
    wire signed [31:0] cla_result, step_result, shifted_upper, shifted_lower;
    wire extra, shifted_extra, e;

    wire [31:0] multiplier, w2, w3;
    wire w4, overflow1, overflow2;

    // e is 0 if counter is 0, 1 otherwise
    assign e = (count[0] | count[1] | count[2] | count[3]);
    assign multiplicand = data_operandA;
    assign multiplier = data_operandB; 

    // Registers for first/second half of products and extra bit
    register_neg upper_product(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
    	.clear(clr), .data(shifted_upper), .data_out(w3));

    register_neg lower_product(.clock(clock), .input_enable(1'b1), .output_enable(1'b1), 
    	.clear(clr), .data(shifted_lower), .data_out(w2));

    dffe_neg extra_bit(.q(w4), .d(shifted_extra), .clk(clock), .en(1'b1), .clr(clr));

    // Assigning starting values if counter started at 0
    assign extra = e ? w4 : 1'b0;
    assign lower_prod = e ? w2 : multiplier;
    assign upper_prod = e ? w3 : 32'b0;

    // Control logic, modified Booth
	control ctrl(.in({lower_prod[1:0], extra}), .aos(subtract), .sm(shift), .nop(nop), .done(data_resultRDY), .clr(clr), .clk(clock), .count(count));

    // ALU operation, add or subtract shifted or nonshifted
	assign multiplicand_after_shift = shift ? (multiplicand << 1) : multiplicand;
    wire [4:0] opcode = {4'b0, subtract};
    alu step_adder(.data_operandA(upper_prod), .data_operandB(multiplicand_after_shift), 
        .ctrl_ALUopcode(opcode), .ctrl_shiftamt(5'b0),
        .data_result(cla_result), .isNotEqual(), .isLessThan(), .overflow());

    // If nop, mux in previous value instead of new value
	assign step_result = nop ? upper_prod : cla_result;

    // Shift product
	assign shifted_extra = lower_prod[1];
	assign shifted_lower[29:0] = lower_prod[31:2];
	assign shifted_lower[31:30] = step_result[1:0];
	assign shifted_upper = step_result >>> 2;

    // Assign results
    assign data_result = shifted_lower;
    assign overflow1 = ~((&shifted_upper & shifted_lower[31]) | ~(|shifted_upper | shifted_lower[31]));
    assign overflow2 = shifted_upper[31] & (~data_operandA[31] & ~data_operandB[31] | & data_operandA[31] & data_operandB[31]);
    assign data_exception = overflow1 | overflow2;

endmodule