module check_bounds(inNote, note_x, note_y, note_width, curr_x, curr_y);
    // check if current x and y are within a note
    input [20:0] note_y;
    input [9:0] note_x, curr_x;
    input [8:0] curr_y;
    input [6:0] note_width;

    output inNote; // high if x and y are within the note

    wire top, left, right, bottom;
    assign top = curr_y > note_y;
    assign left = curr_x > note_x;
    assign right = curr_x < note_x + note_width;
    assign bottom = curr_y < note_y + note_width;
    
    and(inNote, top, left, right, bottom);

endmodule