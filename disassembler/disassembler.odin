package decoding

import "core:fmt"
import "core:os"
import "core:strings"

DEBUG :: true

MOV :: 0b100010
D :: 0b10
W :: 0b1
MOD :: 0b11000000
REG :: 0b00111000
RM :: 0b00000111

Instruction :: struct {
	first_read:  bool,
	second_read: bool,
	w:           bool,
	d:           bool,
	mod:         u8,
	reg:         u8,
	rm:          u8,
}

init_instruction :: proc() -> Instruction {
	return Instruction{false, false, false, false, 0, 0, 0}
}

main :: proc() {
	if len(os.args) != 2 {
		fmt.print("Usage: disassembler <filePath>")
		return
	}
	path := os.args[1]
	data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		fmt.eprintf("cannot read file %v\n", path)
	}
	defer delete(data)

	instruction := init_instruction()

	index := 0
	for index <= len(data) {
		if !instruction.first_read { 	//its instruction
			b := eat_byte(&index, &data)
			if ((b >> 2) & MOV) == MOV { 	// mov
				debug_log(" [%b|D:%b|W:%b] ", (b >> 2), (b & D) >> 1, (b & W))
				fmt.print("mov")
				if b & D == D { 	// d
					//fmt.print(" b")
					instruction.d = true
				}
				if b & W == W { 	// w 
					//fmt.print(" w")
					instruction.w = true
				}
				instruction.first_read = true
			}
		} else if instruction.first_read && !instruction.second_read { 	//then operand
			b := eat_byte(&index, &data)
			instruction.mod = (b & MOD) >> 6
			instruction.reg = (b & REG) >> 3
			instruction.rm = (b & RM)
			instruction.second_read = true

			debug_log(" [mod:%b|reg:%b|rm:%b] ", instruction.mod, instruction.reg, instruction.rm)

			if instruction.mod == 0b11 {
				dest: string
				switch instruction.rm {
				case 0b000:
					dest = instruction.w ? "ax" : "al"
				case 0b001:
					dest = instruction.w ? "cx" : "cl"
				case 0b010:
					dest = instruction.w ? "dx" : "dl"
				case 0b011:
					dest = instruction.w ? "bx" : "bl"
				case 0b100:
					dest = instruction.w ? "sp" : "ah"
				case 0b101:
					dest = instruction.w ? "bp" : "ch"
				case 0b110:
					dest = instruction.w ? "si" : "dh"
				case 0b111:
					dest = instruction.w ? "di" : "bh"
				}
				fmt.printf(" %v,", dest)

				source: string
				switch instruction.reg {
				case 0b000:
					source = instruction.w ? "ax" : "al"
				case 0b001:
					source = instruction.w ? "cx" : "cl"
				case 0b010:
					source = instruction.w ? "dx" : "dl"
				case 0b011:
					source = instruction.w ? "bx" : "bl"
				case 0b100:
					source = instruction.w ? "sp" : "ah"
				case 0b101:
					source = instruction.w ? "bp" : "ch"
				case 0b110:
					source = instruction.w ? "si" : "dh"
				case 0b111:
					source = instruction.w ? "di" : "bh"
				}
				fmt.printf(" %v", source)
				fmt.println("")
			} else if instruction.mod == 0b00 {
				dest: string
				switch instruction.rm {
				case 0b000:
					dest = instruction.w ? "ax" : "al"
				case 0b001:
					dest = instruction.w ? "cx" : "cl"
				case 0b010:
					dest = instruction.w ? "dx" : "dl"
				case 0b011:
					dest = instruction.w ? "bx" : "bl"
				case 0b100:
					dest = instruction.w ? "sp" : "ah"
				case 0b101:
					dest = instruction.w ? "bp" : "ch"
				case 0b110:
					dest = instruction.w ? "si" : "dh"
				case 0b111:
					dest = instruction.w ? "di" : "bh"
				}
				fmt.printf(" %v,", dest)
			}
			//ras 
			instruction = init_instruction()
		}
	}
}

eat_byte :: proc(index: ^int, data: ^([]u8)) -> u8 {
	if (index^ >= len(data)) {
		//fmt.eprintln("out of range")
		os.exit(0)
	}
	result := data[index^]
	index^ += 1
	return result
}

debug_log :: proc(format: string, args: ..any) {
	if DEBUG {
		fmt.printf(format, ..args)
	}
}
