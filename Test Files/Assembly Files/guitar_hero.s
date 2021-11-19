.text

nop
nop
nop
nop
nop
Setup:
	addi $r29, $r0, 1 # r29 is always == 1
	addi $r28, $r0, 0 # r28 is the score register
	addi $r1, $r0, 0 # strum register starts at 0
	addi $r2, $r0, 1
Loop:
	bne $r1, $r0, Strum
	nop
	nop
	j Loop
	nop
	nop
Strum:
	blt $r2, $r29, Subtract
	nop
	nop
	addi $r28, $r28, 100 # add to the score if the buttons were correct
	j Reset
	nop
	nop
Subtract:
	addi $r28, $r28, -100 # Subtract from the score if the buttons were incorrect
	j Reset
	nop
	nop
Reset:
	addi $r1, $r0, 0
	addi $r2, $r0, 1
	j Loop
	nop
	nop
