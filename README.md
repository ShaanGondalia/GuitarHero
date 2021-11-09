# Processor
## NAME (NETID)
Shaan Gondalia (sg491)

## Description of Design
This is a 5-stage pipelined 32-bit processor, with stages Fetch, Decode, Execute, Memory, and Writeback. The pipeline registers are all clocked on the negative edge of the clock. This processor implements a MIPS-like instruction set, with 32 registers.

The pipeline registers and hardware components (such as the alu, regfile, and dmem) are found in processor.v. All control, bypassing, and stalling logic is located in the control folder. 

## Bypassing
This processor implements MX, WX, and WM bypassing. All bypassing logic is contained in bypass.v.

## Stalling
This processor stalls by inserting no-ops into the d/x instruction register. The stalling control is found in stall.v. Multiplication and Division instructions each stall the processor for 16 cycles.

## Optimizations
Branches are assumed not taken, and instructions are flushed accordingly. 

## Bugs
