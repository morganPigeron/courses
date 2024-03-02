package decoding

import "core:fmt"
import "core:os"
import "core:strings"

DEBUG :: false

MOV :: 0b100010
D :: 0b10
W :: 0b1
MOD :: 0b11000000
REG :: 0b00111000
RM :: 0b00000111

MOV_IMM :: 0b1011
W_IMM :: 0b00001000
REG_IMM :: 0b00000111
Instruction :: struct {
	w:     bool,
	d:     bool,
	mod:   u8,
	reg:   u8,
	rm:    u8,
	bytes: [6]u8, //for now max len of instruction is 6 bytes
}

init_instruction :: proc() -> Instruction {
	return Instruction{false, false, 0, 0, 0, [6]u8{}}
}

set_flags_register_to_register :: proc(instruction: ^Instruction) {
	instruction.d = instruction.bytes[0] & D == D
	instruction.w = instruction.bytes[0] & W == W
	instruction.mod = (instruction.bytes[1] & MOD) >> 6
	instruction.reg = (instruction.bytes[1] & REG) >> 3
	instruction.rm = (instruction.bytes[1] & RM)
}

set_flags_immediate_to_register :: proc(instruction: ^Instruction) {
	instruction.w = (instruction.bytes[0] & W_IMM) == W_IMM
	instruction.reg = (instruction.bytes[0] & REG_IMM)
}

get_reg :: proc(i: ^Instruction) -> string {
	switch i.reg {
	case 0b000:
		return i.w ? "ax" : "al"
	case 0b001:
		return i.w ? "cx" : "cl"
	case 0b010:
		return i.w ? "dx" : "dl"
	case 0b011:
		return i.w ? "bx" : "bl"
	case 0b100:
		return i.w ? "sp" : "ah"
	case 0b101:
		return i.w ? "bp" : "ch"
	case 0b110:
		return i.w ? "si" : "dh"
	case 0b111:
		return i.w ? "di" : "bh"
	}
	fmt.eprintf("cannot find register %v %v", i.reg, i.w)
	os.exit(-1)
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
		b := eat_byte(&index, &data)
		instruction.bytes[0] = b

		if (b >> 2) == MOV { 	// MOV register to/from register
			debug_log(" [%b|D:%b|W:%b] ", (b >> 2), (b & D) >> 1, (b & W))
			fmt.print("mov")

			b := eat_byte(&index, &data)
			instruction.bytes[1] = b
			set_flags_register_to_register(&instruction)
			debug_log(" [MOD:%b|REG:%b|R/M:%b] ", instruction.mod, instruction.reg, instruction.rm)
			if instruction.mod == 0b11 {
				rm: string
				switch instruction.rm {
				case 0b000:
					rm = instruction.w ? "ax" : "al"
				case 0b001:
					rm = instruction.w ? "cx" : "cl"
				case 0b010:
					rm = instruction.w ? "dx" : "dl"
				case 0b011:
					rm = instruction.w ? "bx" : "bl"
				case 0b100:
					rm = instruction.w ? "sp" : "ah"
				case 0b101:
					rm = instruction.w ? "bp" : "ch"
				case 0b110:
					rm = instruction.w ? "si" : "dh"
				case 0b111:
					rm = instruction.w ? "di" : "bh"
				}
				fmt.printf(" %v,", rm)

				reg: string
				switch instruction.reg {
				case 0b000:
					reg = instruction.w ? "ax" : "al"
				case 0b001:
					reg = instruction.w ? "cx" : "cl"
				case 0b010:
					reg = instruction.w ? "dx" : "dl"
				case 0b011:
					reg = instruction.w ? "bx" : "bl"
				case 0b100:
					reg = instruction.w ? "sp" : "ah"
				case 0b101:
					reg = instruction.w ? "bp" : "ch"
				case 0b110:
					reg = instruction.w ? "si" : "dh"
				case 0b111:
					reg = instruction.w ? "di" : "bh"
				}
				fmt.printf(" %v", reg)
			} else if instruction.mod == 0b00 {
				reg := get_reg(&instruction)
				rm: string
				switch instruction.rm {
				case 0b000:
					rm = "[bx + si]"
				case 0b001:
					rm = "[bx + di]"
				case 0b010:
					rm = "[bp + si]"
				case 0b011:
					rm = "[bp + di]"
				case 0b100:
					rm = "[si]"
				case 0b101:
					rm = "[di]"
				case 0b110:
					rm = "[bp]"
				case 0b111:
					rm = "[bx]"
				}

				if instruction.d {
					fmt.printf(" %v, %v", reg, rm)
				} else {
					fmt.printf(" %v, %v", rm, reg)
				}

			} else if instruction.mod == 0b01 {
				reg := get_reg(&instruction)
				rm: string
				switch instruction.rm {
				case 0b000:
					rm = "[bx + si"
				case 0b001:
					rm = "[bx + di"
				case 0b010:
					rm = "[bp + si"
				case 0b011:
					rm = "[bp + di"
				case 0b100:
					rm = "[si"
				case 0b101:
					rm = "[di"
				case 0b110:
					rm = "[bp"
				case 0b111:
					rm = "[bx"
				}

				instruction.bytes[2] = eat_byte(&index, &data)
				d8 := instruction.bytes[2]
				if (d8 > 0) {
					rm = fmt.aprintf("%v + %v]", rm, d8)
				} else {
					rm = fmt.aprintf("%v]", rm)
				}

				if instruction.d {
					fmt.printf(" %v, %v", reg, rm)
				} else {
					fmt.printf(" %v, %v", rm, reg)
				}

			} else if instruction.mod == 0b10 {
				reg := get_reg(&instruction)

				rm: string
				switch instruction.rm {
				case 0b000:
					rm = "[bx + si"
				case 0b001:
					rm = "[bx + di"
				case 0b010:
					rm = "[bp + si"
				case 0b011:
					rm = "[bp + di"
				case 0b100:
					rm = "[si"
				case 0b101:
					rm = "[di"
				case 0b110:
					rm = "[bp"
				case 0b111:
					rm = "[bx"
				}

				instruction.bytes[2] = eat_byte(&index, &data)
				instruction.bytes[3] = eat_byte(&index, &data)
				d16 := u16(instruction.bytes[2]) + (u16(instruction.bytes[3]) << 8)
				if (d16 > 0) {
					rm = fmt.aprintf("%v + %v]", rm, d16)
				} else {
					rm = fmt.aprintf("%v]", rm)
				}

				if instruction.d {
					fmt.printf(" %v, %v", reg, rm)
				} else {
					fmt.printf(" %v, %v", rm, reg)
				}
			}
			fmt.println("")
			instruction = init_instruction()
		} else if (b >> 4) == MOV_IMM { 	// MOV immediate to register
			set_flags_immediate_to_register(&instruction)
			debug_log(" [%b|W:%v|REG:%b] ", (b >> 4), (b & W_IMM) >> 3, instruction.reg)
			fmt.print("mov")
			reg := get_reg(&instruction)
			instruction.bytes[1] = eat_byte(&index, &data)
			if instruction.w {
				instruction.bytes[2] = eat_byte(&index, &data)
				low: u16 = u16(instruction.bytes[1])
				high: u16 = u16(instruction.bytes[2]) << 8
				fmt.printf(" %v, %v", reg, low + high)
			} else {
				fmt.printf(" %v, %v", reg, instruction.bytes[1])
			}
			fmt.println("")
			instruction = init_instruction()
		}
	}
}

eat_byte :: proc(index: ^int, data: ^([]u8)) -> u8 {
	if (index^ >= len(data)) {
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
