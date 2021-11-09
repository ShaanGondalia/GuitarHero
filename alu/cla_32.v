module cla_32(A, B, Cin, S, Cout, And, Or);
        
    input [31:0] A, B;
    input Cin;

    output [31:0] S, And, Or;
    output Cout;

    wire [31:0] test;
    wire P0, P1, P2, P3, G0, G1, G2, G3, C8, C16, C24, C32;

    cla_8 block0(.A(A[7:0]), .B(B[7:0]), .Cin(Cin),
                 .S(S[7:0]), .G(And[7:0]), .P(Or[7:0]), .Gout(G0), .Pout(P0));
    wire w1;
    and w_1(w1, P0, Cin);
    or c8(C8, w1, G0);

    cla_8 block1(.A(A[15:8]), .B(B[15:8]), .Cin(C8),
                 .S(S[15:8]), .G(And[15:8]), .P(Or[15:8]), .Gout(G1), .Pout(P1));

    wire w2, w3;
    and w_2(w2, P1, G0);
    and w_3(w3, P1, P0, Cin);
    or c16(C16, w2, w3, G1);

    cla_8 block2(.A(A[23:16]), .B(B[23:16]), .Cin(C16),
                 .S(S[23:16]), .G(And[23:16]), .P(Or[23:16]), .Gout(G2), .Pout(P2));

    wire w4, w5, w6;
    and w_4(w4, P2, G1);
    and w_5(w5, P2, P1, G0);
    and w_6(w6, P2, P1, P0, Cin);
    or c24(C24, w4, w5, w6, G2);

    cla_8 block3(.A(A[31:24]), .B(B[31:24]), .Cin(C24),
                 .S(S[31:24]), .G(And[31:24]), .P(Or[31:24]), .Gout(G3), .Pout(P3));

    wire w7, w8, w9, w10;
    and w_7(w7, P3, G2);
    and w_8(w8, P3, P2, G1);
    and w_9(w9, P3, P2, P1, G0);
    and w_10(w10, P3, P2, P1, P0, Cin);
    or c32(C32, w7, w8, w9, w10, G3);
    assign Cout = C32;


endmodule