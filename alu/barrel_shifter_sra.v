module barrel_shifter_sra(A, shift, res);

	input [31:0] A;
    input [4:0] shift;

    output [31:0] res;

    wire [31:0] sri2, sri3, sri4, sri5;
    wire [31:0] sro1, sro2, sro3, sro4, sro5;

    sra_16 block1(.in(A), .out(sro1));
    mux_2 mux1(sri2, shift[4], A, sro1);
    sra_8 block2(.in(sri2), .out(sro2));
    mux_2 mux2(sri3, shift[3], sri2, sro2);
    sra_4 block3(.in(sri3), .out(sro3));
    mux_2 mux3(sri4, shift[2], sri3, sro3);
    sra_2 block4(.in(sri4), .out(sro4));
    mux_2 mux4(sri5, shift[1], sri4, sro4);
    sra_1 block5(.in(sri5), .out(sro5));
    mux_2 mux5(res, shift[0], sri5, sro5);

endmodule