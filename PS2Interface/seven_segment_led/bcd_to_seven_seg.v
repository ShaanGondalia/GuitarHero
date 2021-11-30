module bcd_to_seven_seg (input [3:0] val_in, output [6:0] led_out);

    // val_in is in BCD format, 4 bits used to describe 0-9 in decimal

    // LED out LSB is G, MSB is A

    // SOP product terms for each decimal value
    wire bcd0, bcd1, bcd2, bcd3, bcdd4, bcd5, bcd6, bcd7, bcd8, bcd9;

    assign bcd0 = ~val_in[3] & ~val_in[2] & ~val_in[1] & ~val_in[0];
    assign bcd1 = ~val_in[3] & ~val_in[2] & ~val_in[1] & val_in[0];
    assign bcd2 = ~val_in[3] & ~val_in[2] & val_in[1] & ~val_in[0];
    assign bcd3 = ~val_in[3] & ~val_in[2] & val_in[1] & val_in[0];
    assign bcd4 = ~val_in[3] & val_in[2] & ~val_in[1] & ~val_in[0];
    assign bcd5 = ~val_in[3] & val_in[2] & ~val_in[1] & val_in[0];
    assign bcd6 = ~val_in[3] & val_in[2] & val_in[1] & ~val_in[0];
    assign bcd7 = ~val_in[3] & val_in[2] & val_in[1] & val_in[0];
    assign bcd8 = val_in[3] & ~val_in[2] & ~val_in[1] & ~val_in[0];
    assign bcd9 = val_in[3] & ~val_in[2] & ~val_in[1] & val_in[0];
    
    // A
    assign led_out[6] = bcd1 | bcd4;

    // B
    assign led_out[5] = bcd5 | bcd6;

    // C
    assign led_out[4] = bcd2;

    // D
    assign led_out[3] = bcd1 | bcd4 | bcd7;

    // E
    assign led_out[2] = bcd1 | bcd3 | bcd4 | bcd5 | bcd7 | bcd9;

    // F
    assign led_out[1] = bcd1 | bcd2 | bcd3 | bcd7;

    // G
    assign led_out[0] = bcd0 | bcd1 | bcd7;

endmodule