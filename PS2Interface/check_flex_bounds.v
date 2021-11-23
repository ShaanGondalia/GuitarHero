module check_bounds(inNote, note_x, note_y, note_width_x, note_width_y, curr_x, curr_y);
    // check if current x and y are within an object with width x and y
    input [31:0] note_y;
    input [9:0] note_x, curr_x;
    input [8:0] curr_y;
    input [6:0] note_width_x, note_width_y;

    output inNote; // high if x and y are within the object

    wire top, left, right, bottom;
    assign top = curr_y > note_y;
    assign left = curr_x > note_x;
    assign right = curr_x < note_x + note_width_x;
    assign bottom = curr_y < note_y + note_width_y;
    
    and(inNote, top, left, right, bottom);

endmodule