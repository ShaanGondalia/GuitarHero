module seven_segment(input clk_in, 
                     input rst_in, 
                     input [31:0] score, // in binary format
                     input [13:0] speed,
                     input [13:0] level,
                     output [7:0] cat_out, // LSB is G, MSB - 1 is A
                     output [7:0] an_out);

    // take a binary 32 bit value, convert to BCD, switch between 4 bits of BCD, then convert to cathode values and anode

    reg [7:0] segment_state = 8'b00000001;
    reg [31:0] segment_counter = 32'd0;
    reg [3:0] routed_vals;
    wire [6:0] led_out;

    wire [15:0] bcd_low;
    wire [15:0] bcd_level;
    wire [15:0] bcd_speed;
    bin2bcd bintobcdlow(score[13:0], bcd_low);
    bin2bcd bintobcdlevel(level, bcd_level);
    bin2bcd bintobcdspeed(speed, bcd_speed);
    
    bcd_to_seven_seg my_converter (.val_in(routed_vals),.led_out(led_out));
    assign cat_out = {1'b1, led_out}; // make decimal the 1
    assign an_out = ~segment_state;
    
    
    always @(posedge clk_in) begin
        if (rst_in)begin
            segment_state = 8'b00000001;
        end else begin
            segment_state = {segment_state[6:0],segment_state[7]};
        end
        
        case(segment_state)
            8'b00000001:   routed_vals = bcd_low[3:0];
            8'b00000010:   routed_vals = bcd_low[7:4];
            8'b00000100:   routed_vals = bcd_low[11:8];
            8'b00001000:   routed_vals = bcd_low[15:12];
            8'b00010000:   routed_vals = bcd_speed[3:0];
            8'b00100000:   routed_vals = bcd_speed[7:4];
            8'b01000000:   routed_vals = bcd_level[3:0];
            8'b10000000:   routed_vals = bcd_level[7:4];
            default:   routed_vals = bcd_low[3:0];
        endcase
    end
        
endmodule