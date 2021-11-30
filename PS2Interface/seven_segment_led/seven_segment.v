module seven_segment(input clk_in, 
                     input rst_in, 
                     input [31:0] val_in, // in binary format
                     output [7:0] cat_out, // LSB is G, MSB - 1 is A
                     output [3:0] an_out);

    // take a binary 32 bit value, convert to BCD, switch between 4 bits of BCD, then convert to cathode values and anode

    reg [3:0] segment_state = 4'b0001;
    reg [31:0] segment_counter = 32'd0;
    reg [3:0] routed_vals;
    wire [6:0] led_out;

    wire [15:0] bcd;
    bin2bcd bintobcd(val_in[13:0], bcd);
    
    bcd_to_seven_seg my_converter (.val_in(routed_vals),.led_out(led_out));
    assign cat_out = {1'b1, led_out}; // make decimal the 1
    assign an_out = ~segment_state;
    
    always @(segment_state) begin
        case(segment_state)
            4'b0001:   routed_vals = bcd[3:0];
            4'b0010:   routed_vals = bcd[7:4];
            4'b0100:   routed_vals = bcd[11:8];
            4'b1000:   routed_vals = bcd[15:12];
            default:   routed_vals = bcd[3:0];
        endcase
    end
    
    always @(posedge clk_in) begin
        if (rst_in)begin
            segment_state <= 4'b0001;
            segment_counter <= 32'b0;
        end else begin
            if (segment_counter == 32'd100)begin
                segment_counter <= 32'd0;
                segment_state <= {segment_state[2:0],segment_state[3]};
            end else begin
                segment_counter <= segment_counter + 1;
            end
        end
    end
        
endmodule