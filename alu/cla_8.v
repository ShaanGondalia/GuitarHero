module cla_8(A, B, Cin, S, G, P, Gout, Pout);
        
    input [7:0] A, B;
    input Cin;

    output [7:0] S, G, P;
    output Gout, Pout;

    wire [7:0] C;

    // Generate all Ps and Gs:
    and g0(G[0], A[0], B[0]);
    and g1(G[1], A[1], B[1]);
    and g2(G[2], A[2], B[2]);
    and g3(G[3], A[3], B[3]);
    and g4(G[4], A[4], B[4]);
    and g5(G[5], A[5], B[5]);
    and g6(G[6], A[6], B[6]);
    and g7(G[7], A[7], B[7]);

    or p0(P[0], A[0], B[0]);
    or p1(P[1], A[1], B[1]);
    or p2(P[2], A[2], B[2]);
    or p3(P[3], A[3], B[3]);
    or p4(P[4], A[4], B[4]);
    or p5(P[5], A[5], B[5]);
    or p6(P[6], A[6], B[6]);
    or p7(P[7], A[7], B[7]);

    // Calculate C and S for all stages

    assign C[0] = Cin;
    xor s0(S[0], A[0], B[0], C[0]);

    wire w1;
    and w_1(w1, P[0], C[0]);
    or c1(C[1], w1, G[0]);
    xor s1(S[1], A[1], B[1], C[1]);

    wire w2, w3;
    and w_2(w2, P[1], G[0]);
    and w_3(w3, P[1], P[0], C[0]);
    or c2(C[2], w2, w3, G[1]);
    xor s2(S[2], A[2], B[2], C[2]);

    wire w4, w5, w6;
    and w_4(w4, P[2], G[1]);
    and w_5(w5, P[2], P[1], G[0]);
    and w_6(w6, P[2], P[1], P[0], C[0]);
    or c3(C[3], w4, w5, w6, G[2]);
    xor s3(S[3], A[3], B[3], C[3]);

    wire w7, w8, w9, w10;
    and w_7(w7, P[3], G[2]);
    and w_8(w8, P[3], P[2], G[1]);
    and w_9(w9, P[3], P[2], P[1], G[0]);
    and w_10(w10, P[3], P[2], P[1], P[0], C[0]);
    or c4(C[4], w7, w8, w9, w10, G[3]);
    xor s4(S[4], A[4], B[4], C[4]);

    wire w11, w12, w13, w14, w15;
    and w_11(w11, P[4], G[3]);
    and w_12(w12, P[4], P[3], G[2]);
    and w_13(w13, P[4], P[3], P[2], G[1]);
    and w_14(w14, P[4], P[3], P[2], P[1], G[0]);
    and w_15(w15, P[4], P[3], P[2], P[1], P[0], C[0]);
    or c5(C[5], w11, w12, w13, w14, w15, G[4]);
    xor s5(S[5], A[5], B[5], C[5]);

    wire w16, w17, w18, w19, w20, w21;
    and w_16(w16, P[5], G[4]);
    and w_17(w17, P[5], P[4], G[3]);
    and w_18(w18, P[5], P[4], P[3], G[2]);
    and w_19(w19, P[5], P[4], P[3], P[2], G[1]);
    and w_20(w20, P[5], P[4], P[3], P[2], P[1], G[0]);
    and w_21(w21, P[5], P[4], P[3], P[2], P[1], P[0], C[0]);
    or c6(C[6], w16, w17, w18, w19, w20, w21, G[5]);
    xor s6(S[6], A[6], B[6], C[6]);

    wire w22, w23, w24, w25, w26, w27, w28;
    and w_22(w22, P[6], G[5]);
    and w_23(w23, P[6], P[5], G[4]);
    and w_24(w24, P[6], P[5], P[4], G[3]);
    and w_25(w25, P[6], P[5], P[4], P[3], G[2]);
    and w_26(w26, P[6], P[5], P[4], P[3], P[2], G[1]);
    and w_27(w27, P[6], P[5], P[4], P[3], P[2], P[1], G[0]);
    and w_28(w28, P[6], P[5], P[4], P[3], P[2], P[1], P[0], C[0]);
    or c7(C[7], w22, w23, w24, w25, w26, w27, w28, G[6]);
    xor s7(S[7], A[7], B[7], C[7]);

    wire w29, w30, w31, w32, w33, w34, w35;
    and w_29(w29, P[7], G[6]);
    and w_30(w30, P[7], P[6], G[5]);
    and w_31(w31, P[7], P[6], P[5], G[4]);
    and w_32(w32, P[7], P[6], P[5], P[4], G[3]);
    and w_33(w33, P[7], P[6], P[5], P[4], P[3], G[2]);
    and w_34(w34, P[7], P[6], P[5], P[4], P[3], P[2], G[1]);
    and w_35(w35, P[7], P[6], P[5], P[4], P[3], P[2], P[1], G[0]);

    or g_out(Gout, w29, w30, w31, w32, w33, w34, w35, G[7]);
    and p_out(Pout, P[7], P[6], P[5], P[4], P[3], P[2], P[1], P[0]);

endmodule