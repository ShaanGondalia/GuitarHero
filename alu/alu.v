module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    wire [31:0] cla_result, and_result, or_result, sll_result, sra_result, cla_b, not_b;
    wire cout, notA31, notB31, notResult31, subtract, w1;
    wire pos_over, neg_over, nnn, np, ppn, eq;

    // Adder Logic
    not_32 negate_b(.result(not_b), .in(data_operandB));
    not temp(w1, ctrl_ALUopcode[1]);
    and sub(subtract, ctrl_ALUopcode[0], w1);
    mux_2 arithmetic(.out(cla_b), .select(subtract), .in0(data_operandB), .in1(not_b));

    cla_32 cla(.A(data_operandA), .B(cla_b), .Cin(ctrl_ALUopcode[0]),
    		   .S(cla_result), .Cout(cout), .And(and_result), .Or(or_result));


    // Information Signals
    not(notA31, data_operandA[31]);
    not(notB31, cla_b[31]);
    not(notResult31, cla_result[31]);
    and add_overflow_pos(pos_over, notA31, notB31, cla_result[31]);
    and add_overflow_neg(neg_over, data_operandA[31], cla_b[31], notResult31);
    or add_overflow_result(overflow, pos_over, neg_over);

    and(nnn, data_operandA[31], notB31, cla_result[31]);
    and(np, data_operandA[31], cla_b[31]);
    and(ppn, notA31, cla_b[31], cla_result[31]);
    or(isLessThan, nnn, np, ppn);

    or_32 neq(isNotEqual, cla_result);

    // sll barrel shifter
    barrel_shifter_sll sll(.A(data_operandA), .shift(ctrl_shiftamt), .res(sll_result));

    // sra barrel shifter
    barrel_shifter_sra sra(.A(data_operandA), .shift(ctrl_shiftamt), .res(sra_result));

    // Add = 00000
    // Subtract = 00001
    // And = 00010
    // Or = 00011
    // SLL = 00100
    // SRA = 00101
    // Which output gets sent
    mux_8 mux(data_result, ctrl_ALUopcode[2:0], cla_result, cla_result, and_result, or_result, sll_result, sra_result, 0, 0);

endmodule