package decoding

import "core:fmt"
import "core:os"
import "core:strings"

MOV :: 0b100010
D :: 0b10
W :: 0b1
MOD :: 0b11000000
REG :: 0b00111000
RM :: 0b00000111

main :: proc() {
	//path := "listing_0037_single_register_mov.txt"
	path := "listing_0038_many_register_mov.txt"
	data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		fmt.eprintf("cannot read file %v\n", path)
	}
	defer delete(data)

	//init
	instruction_read := false
	w := false
	d := false

	for b in data[:] {
		if !instruction_read { 	//its instruction
			if ((b >> 2) & MOV) == MOV { 	// mov
				fmt.print("mov")
				if b & D == D { 	// d
					//fmt.print(" b")
					d = true
				}
				if b & W == W { 	// w 
					//fmt.print(" w")
					w = true
				}
				instruction_read = true
			}
		} else { 	//then operand
			mod := (b & MOD) >> 6
			reg := (b & REG) >> 3
			rm := (b & RM)

			if mod == 0b11 {
				dest: string
				switch rm {
				case 0b000:
					dest = w ? "ax" : "al"
				case 0b001:
					dest = w ? "cx" : "cl"
				case 0b010:
					dest = w ? "dx" : "dl"
				case 0b011:
					dest = w ? "bx" : "bl"
				case 0b100:
					dest = w ? "sp" : "ah"
				case 0b101:
					dest = w ? "bp" : "ch"
				case 0b110:
					dest = w ? "si" : "dh"
				case 0b111:
					dest = w ? "di" : "bh"
				}
				fmt.printf(" %v,", dest)

				source: string
				switch reg {
				case 0b000:
					source = w ? "ax" : "al"
				case 0b001:
					source = w ? "cx" : "cl"
				case 0b010:
					source = w ? "dx" : "dl"
				case 0b011:
					source = w ? "bx" : "bl"
				case 0b100:
					source = w ? "sp" : "ah"
				case 0b101:
					source = w ? "bp" : "ch"
				case 0b110:
					source = w ? "si" : "dh"
				case 0b111:
					source = w ? "di" : "bh"
				}
				fmt.printf(" %v", source)
				fmt.println("")
			}

			//ras 
			instruction_read = false
			w = false
			d = false

		}

	}
}
