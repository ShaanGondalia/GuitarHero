.text

nop			# Initialize Values
nop
nop
nop
addi $r3, $r0, 1	# r3 = 1
addi $r4, $r0, 35	# r4 = 35
addi $r1, $r0, 3	# r1 = 3
addi $r2, $r0, 21	# r2 = 21
sub $r3, $r0, $r3	# r3 = -1
sub $r4, $r0, $r4	# r4 = -35
nop
nop
nop 
nop 			# Load/Store Tests
sw $r1, 1($r0) 		# mem[1] = r1 = 3
sw $r2, 2($r0) 		# mem[2] = r2 = 21
sw $r3, 0($r1) 		# mem[r1] = r3 = -1 (should be mem[3])
nop
nop
nop
lw $r16, 1($r0) 	# r16 = mem[1] = 3
lw $r17, 2($r0) 	# r17 = mem[2] = 21
lw $r18, 0($r1) 	# r18 = mem[3] = -1