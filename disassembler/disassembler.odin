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

MOV_IMM :: 0b1011
W_IMM :: 0b00001000
REG_IMM :: 0b00000111

Result: [1024]string = {}
Index_result := 0

add_to_result :: proc(arg: string) {
	Result[Index_result] = arg
	Index_result += 1
}

print_result :: proc() {
	for i in 0 ..< Index_result {
		fmt.print(Result[i])
	}
}

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

get_reg :: proc(addr: u8, w: bool) -> string {
	switch addr {
	case 0b000:
		return w ? "ax" : "al"
	case 0b001:
		return w ? "cx" : "cl"
	case 0b010:
		return w ? "dx" : "dl"
	case 0b011:
		return w ? "bx" : "bl"
	case 0b100:
		return w ? "sp" : "ah"
	case 0b101:
		return w ? "bp" : "ch"
	case 0b110:
		return w ? "si" : "dh"
	case 0b111:
		return w ? "di" : "bh"
	}
	fmt.eprintf("cannot find register %v %v", addr, w)
	os.exit(-1)
}

get_rm :: proc(rm: u8) -> string {
	switch rm {
	case 0b000:
		return "[bx + si"
	case 0b001:
		return "[bx + di"
	case 0b010:
		return "[bp + si"
	case 0b011:
		return "[bp + di"
	case 0b100:
		return "[si"
	case 0b101:
		return "[di"
	case 0b110:
		return "[bp"
	case 0b111:
		return "[bx"
	}
	fmt.eprintf("cannot find rm %v", rm)
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
	parse(&data)
	print_result()
}

eat_byte :: proc(index: ^int, data: ^([]u8)) -> u8 {
	result := data[index^]
	if DEBUG {
		debug_log(" 0x%x ", result)
	}
	index^ += 1
	return result
}

debug_log :: proc(format: string, args: ..any) {
	if DEBUG {
		fmt.printf(format, ..args)
	}
}

parse :: proc(data: ^([]u8)) {
	instruction := init_instruction()
	index := 0
	for index < len(data) {
		b := eat_byte(&index, data)
		instruction.bytes[0] = b

		if (b >> 2) == MOV { 	// MOV register to/from register
			debug_log(" [%b|D:%b|W:%b] ", (b >> 2), (b & D) >> 1, (b & W))
			//fmt.print("mov")
			add_to_result("mov")

			b := eat_byte(&index, data)
			instruction.bytes[1] = b
			set_flags_register_to_register(&instruction)
			debug_log(" [MOD:%b|REG:%b|R/M:%b] ", instruction.mod, instruction.reg, instruction.rm)
			if instruction.mod == 0b11 {
				rm := get_reg(instruction.rm, instruction.w)
				add_to_result(fmt.aprintf(" %v,", rm))

				reg := get_reg(instruction.reg, instruction.w)
				add_to_result(fmt.aprintf(" %v", reg))
			} else if instruction.mod == 0b00 {
				reg := get_reg(instruction.reg, instruction.w)
				rm := get_rm(instruction.rm)
				if instruction.d {
					add_to_result(fmt.aprintf(" %v, %v]", reg, rm))
				} else {
					add_to_result(fmt.aprintf(" %v], %v", rm, reg))
				}

			} else if instruction.mod == 0b01 {
				reg := get_reg(instruction.reg, instruction.w)
				rm := get_rm(instruction.rm)

				instruction.bytes[2] = eat_byte(&index, data)
				d8 := instruction.bytes[2]
				if (d8 > 0) {
					rm = fmt.aprintf("%v + %v]", rm, d8)
				} else {
					rm = fmt.aprintf("%v]", rm)
				}

				if instruction.d {
					add_to_result(fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(fmt.aprintf(" %v, %v", rm, reg))
				}

			} else if instruction.mod == 0b10 {
				reg := get_reg(instruction.reg, instruction.w)
				rm := get_rm(instruction.rm)

				instruction.bytes[2] = eat_byte(&index, data)
				instruction.bytes[3] = eat_byte(&index, data)
				d16 := u16(instruction.bytes[2]) + (u16(instruction.bytes[3]) << 8)
				if (d16 > 0) {
					rm = fmt.aprintf("%v + %v]", rm, d16)
				} else {
					rm = fmt.aprintf("%v]", rm)
				}

				if instruction.d {
					add_to_result(fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(fmt.aprintf(" %v, %v", rm, reg))
				}
			}
			add_to_result("\n")
			instruction = init_instruction()
			debug_log("\n")
		} else if (b >> 4) == MOV_IMM { 	// MOV immediate to register
			set_flags_immediate_to_register(&instruction)
			debug_log(" [%b|W:%v|REG:%b] ", (b >> 4), (b & W_IMM) >> 3, instruction.reg)
			add_to_result("mov")
			reg := get_reg(instruction.reg, instruction.w)
			instruction.bytes[1] = eat_byte(&index, data)
			if instruction.w {
				instruction.bytes[2] = eat_byte(&index, data)
				low: u16 = u16(instruction.bytes[1])
				high: u16 = u16(instruction.bytes[2]) << 8
				add_to_result(fmt.aprintf(" %v, %v", reg, low + high))
			} else {
				add_to_result(fmt.aprintf(" %v, %v", reg, instruction.bytes[1]))
			}
			add_to_result("\n")
			debug_log("\n")
			instruction = init_instruction()
		}
	}
}
