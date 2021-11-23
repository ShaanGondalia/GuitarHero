module intersect(yes, note_y, note_width_y, bar_y, bar_width_y);
    // check if note intersects horizontal bar
    // just checks the y values, x values don't change with time
    input [31:0] note_y;
    input [9:0] bar_y, bar_width_y;
    input [6:0] note_width_y;

    output yes; // high if intersecting

    assign yes = (bar_y + bar_width_y > note_y) && (bar_y < note_y + note_width_y);
    
endmodule