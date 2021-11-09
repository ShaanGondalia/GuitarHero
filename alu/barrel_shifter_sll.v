module barrel_shifter_sll(A, shift, res);

	input [31:0] A;
    input [4:0] shift;

    output [31:0] res;

    wire [31:0] sli2, sli3, sli4, sli5;
    wire [31:0] slo1, slo2, slo3, slo4, slo5;

    sll_16 block1(.in(A), .out(slo1));
    mux_2 mux1(sli2, shift[4], A, slo1);
    sll_8 block2(.in(sli2), .out(slo2));
    mux_2 mux2(sli3, shift[3], sli2, slo2);
    sll_4 block3(.in(sli3), .out(slo3));
    mux_2 mux3(sli4, shift[2], sli3, slo3);
    sll_2 block4(.in(sli4), .out(slo4));
    mux_2 mux4(sli5, shift[1], sli4, slo4);
    sll_1 block5(.in(sli5), .out(slo5));
    mux_2 mux5(res, shift[0], sli5, slo5);

endmodule