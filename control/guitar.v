module guitar(old_strum, new_strum, buttons, intersections, update, inc);
	input old_strum, new_strum;
	input [3:0] buttons, intersections;

	output update;
	output inc;

	assign c0 = (buttons[0] ~^ intersections[0]);
	assign c1 = (buttons[1] ~^ intersections[1]);
	assign c2 = (buttons[2] ~^ intersections[3]);
	assign c3 = (buttons[2] ~^ intersections[3]);

	assign inc = c0 & c1 & c2 & c3; // 1 if all presses are correct, 0 else
	assign update = new_strum & (~old_strum); // Update if new = 1 and old = 0

endmodule