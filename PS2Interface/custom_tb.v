`timescale 1 ns / 100 ps
module custom_tb;
    wire [31:0] in0, in1, in2, in3, in4, in5, in6, in7;

    reg clock = 0;

    wire [31:0] temp1, temp2, temp3, temp4, temp5, temp6;
    wire t1, t2, t3;
	
	integer i;

    integer m0;
    integer m1;
    integer m2;
    integer m3;
    integer m4;
    integer m5;


    assign in0 = m0;
    assign in1 = m1;
    assign in2 = m2;

    ///////////////////
    //
    // iverilog -o f_custom_tb.vvp -s custom_tb custom_tb.v
    //
    ///////////////////

    localparam MAX_NOTES_ON_SCREEN = 16;
    reg[3:0] NOTES[0:MAX_NOTES_ON_SCREEN - 1];

    initial begin
        $display("Loading mem");
        $readmemh("Notes.mem", NOTES);
        #80
        for(i = 0; i < 16; i = i + 1) begin
            #20;
            $display("notes: %b", NOTES[i]);
            $display("1st bit: %b", NOTES[i][3]);
        end
		$finish;
	end

    always
        #40 clock = !clock;

endmodule