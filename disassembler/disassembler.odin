package decoding

import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"

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

ADD :: 0
SUB :: 0b001010
IMM :: 0b100000
CMP :: 0b001110

ADD_IMM_ACC :: 0b10
SUB_IMM_ACC :: 0b0010110
CMP_IMM_ACC :: 0b0011110

Instruction :: struct {
	w:     bool, //word or not 
	d:     bool, //displacement
	s:     bool, //signed or not
	mod:   u8,
	type:  u8,
	reg:   u8,
	rm:    u8,
	bytes: [6]u8, //for now max len of instruction is 6 bytes
}

init_instruction :: proc() -> Instruction {
	return Instruction{false, false, false, 0, 0, 0, 0, [6]u8{}}
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

	parsed := parse(&data)
	defer delete(parsed)

	fmt.print(parsed)
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

set_flags_add_immediate_to_register :: proc(instruction: ^Instruction) {
	instruction.s = instruction.bytes[0] & D == D
	instruction.w = instruction.bytes[0] & W == W
	instruction.mod = (instruction.bytes[1] & MOD) >> 6
	instruction.type = (instruction.bytes[1] & REG) >> 3
	instruction.rm = (instruction.bytes[1] & RM)
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

add_to_result :: proc(parsed: ^([]string), index: ^int, arg: string) {
	parsed[index^] = arg
	index^ += 1
}

result_to_string :: proc(parsed: []string) -> string {
	result: string
	for elem in parsed {
		result = fmt.aprintf("%v%v", result, elem)
	}
	return result
}

parse :: proc(data: ^([]u8)) -> string {
	parsed: []string = make([]string, 1024)
	index_parsed := 0

	instruction := init_instruction()
	index := 0
	for index < len(data) {
		b := eat_byte(&index, data)
		instruction.bytes[0] = b

		if (b >> 2) == MOV { 	// MOV register to/from register
			debug_log(" [%b|D:%b|W:%b] ", (b >> 2), (b & D) >> 1, (b & W))
			//fmt.print("mov")
			add_to_result(&parsed, &index_parsed, "mov")

			b := eat_byte(&index, data)
			instruction.bytes[1] = b
			set_flags_register_to_register(&instruction)
			debug_log(" [MOD:%b|REG:%b|R/M:%b] ", instruction.mod, instruction.reg, instruction.rm)
			if instruction.mod == 0b11 {
				rm := get_reg(instruction.rm, instruction.w)
				add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v,", rm))

				reg := get_reg(instruction.reg, instruction.w)
				add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v", reg))
			} else if instruction.mod == 0b00 {
				reg := get_reg(instruction.reg, instruction.w)
				rm := get_rm(instruction.rm)
				if instruction.d {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v]", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v], %v", rm, reg))
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
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", rm, reg))
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
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", rm, reg))
				}
			}
			add_to_result(&parsed, &index_parsed, "\n")
			instruction = init_instruction()
			debug_log("\n")
		} else if (b >> 4) == MOV_IMM { 	// MOV immediate to register
			set_flags_immediate_to_register(&instruction)
			debug_log(" [%b|W:%v|REG:%b] ", (b >> 4), (b & W_IMM) >> 3, instruction.reg)
			add_to_result(&parsed, &index_parsed, "mov")
			reg := get_reg(instruction.reg, instruction.w)
			instruction.bytes[1] = eat_byte(&index, data)
			if instruction.w {
				instruction.bytes[2] = eat_byte(&index, data)
				low: u16 = u16(instruction.bytes[1])
				high: u16 = u16(instruction.bytes[2]) << 8
				add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", reg, low + high))
			} else {
				add_to_result(
					&parsed,
					&index_parsed,
					fmt.aprintf(" %v, %v", reg, instruction.bytes[1]),
				)
			}
			add_to_result(&parsed, &index_parsed, "\n")
			debug_log("\n")
			instruction = init_instruction()
		} else if (b >> 2) == ADD || (b >> 2) == SUB || (b >> 2) == CMP {
			debug_log(" [%b|D:%b|W:%b] ", (b >> 2), (b & D) >> 1, (b & W))
			//fmt.print("mov")
			if (b >> 2) == ADD {
				add_to_result(&parsed, &index_parsed, "add")
			} else if (b >> 2) == SUB {
				add_to_result(&parsed, &index_parsed, "sub")
			} else if (b >> 2) == CMP {
				add_to_result(&parsed, &index_parsed, "cmp")
			}

			b := eat_byte(&index, data)
			instruction.bytes[1] = b
			set_flags_register_to_register(&instruction)
			debug_log(" [MOD:%b|REG:%b|R/M:%b] ", instruction.mod, instruction.reg, instruction.rm)
			if instruction.mod == 0b11 {
				rm := get_reg(instruction.rm, instruction.w)
				add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v,", rm))

				reg := get_reg(instruction.reg, instruction.w)
				add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v", reg))
			} else if instruction.mod == 0b00 {
				reg := get_reg(instruction.reg, instruction.w)
				rm := get_rm(instruction.rm)
				if instruction.d {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v]", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v], %v", rm, reg))
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
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", rm, reg))
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
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", reg, rm))
				} else {
					add_to_result(&parsed, &index_parsed, fmt.aprintf(" %v, %v", rm, reg))
				}
			}
			add_to_result(&parsed, &index_parsed, "\n")
			instruction = init_instruction()
			debug_log("\n")
		} else if (b >> 2) == IMM {
			b = eat_byte(&index, data)
			instruction.bytes[1] = b
			set_flags_add_immediate_to_register(&instruction)
			debug_log(
				" [S:%v|W:%v|MOD:%b|TYPE:%b|R/M:%b] ",
				instruction.s,
				instruction.w,
				instruction.mod,
				instruction.type,
				instruction.rm,
			)
			if instruction.type == 0b000 { 	//add
				add_to_result(&parsed, &index_parsed, "add")
			} else if instruction.type == 0b101 { 	//sub
				add_to_result(&parsed, &index_parsed, "sub")
			} else if instruction.type == 0b111 {
				add_to_result(&parsed, &index_parsed, "cmp")
			}

			if instruction.mod == 0b11 { 	//no displacement
				reg := get_reg(instruction.rm, instruction.w)
				instruction.bytes[2] = eat_byte(&index, data)
				if instruction.s == false && instruction.w == true {
					instruction.bytes[3] = eat_byte(&index, data)
					if instruction.s {
						add_to_result(
							&parsed,
							&index_parsed,
							fmt.aprintf(
								" %v, %v",
								reg,
								i16(instruction.bytes[2]) + i16(instruction.bytes[3] << 8),
							),
						)
					} else {
						add_to_result(
							&parsed,
							&index_parsed,
							fmt.aprintf(
								" %v, %v",
								reg,
								u16(instruction.bytes[2]) + u16(instruction.bytes[3] << 8),
							),
						)
					}
				} else {
					add_to_result(
						&parsed,
						&index_parsed,
						fmt.aprintf(" %v, %v", reg, i8(instruction.bytes[2])),
					)
				}
				add_to_result(&parsed, &index_parsed, "\n")
				debug_log("\n")
				instruction = init_instruction()
			} else if instruction.mod == 0b00 { 	//no displacement
				reg := get_rm(instruction.rm)
				instruction.bytes[2] = eat_byte(&index, data)
				if instruction.w == false {
					add_to_result(
						&parsed,
						&index_parsed,
						fmt.aprintf(" byte %v], %v", reg, instruction.bytes[2]),
					)
				} else if instruction.mod == 0 && instruction.rm == 0b110 {
					instruction.bytes[3] = eat_byte(&index, data)
					instruction.bytes[4] = eat_byte(&index, data)
					add_to_result(
						&parsed,
						&index_parsed,
						fmt.aprintf(
							" word [%v], %v",
							u16(instruction.bytes[2]) + (u16(instruction.bytes[3]) << 8),
							instruction.bytes[4],
						),
					)
				} else {
					add_to_result(
						&parsed,
						&index_parsed,
						fmt.aprintf(" word %v], %v", reg, instruction.bytes[2]),
					)
				}
				add_to_result(&parsed, &index_parsed, "\n")
				debug_log("\n")
				instruction = init_instruction()
			} else if instruction.mod == 0b10 { 	//word displacement
				reg := get_rm(instruction.rm)
				instruction.bytes[2] = eat_byte(&index, data)
				instruction.bytes[3] = eat_byte(&index, data)
				instruction.bytes[4] = eat_byte(&index, data)
				add_to_result(
					&parsed,
					&index_parsed,
					fmt.aprintf(
						" word %v + %v], %v",
						reg,
						i16(instruction.bytes[2]) + (i16(instruction.bytes[3]) << 8),
						instruction.bytes[4],
					),
				)
				add_to_result(&parsed, &index_parsed, "\n")
				debug_log("\n")
				instruction = init_instruction()
			}
		} else if (b >> 1) == ADD_IMM_ACC || (b >> 1) == SUB_IMM_ACC || (b >> 1) == CMP_IMM_ACC {
			debug_log(" [%b|W:%b] ", (b >> 1), (b & W))
			if (b >> 1) == ADD_IMM_ACC {
				add_to_result(&parsed, &index_parsed, "add")
			} else if (b >> 1) == SUB_IMM_ACC {
				add_to_result(&parsed, &index_parsed, "sub")
			} else if (b >> 1) == CMP_IMM_ACC {
				add_to_result(&parsed, &index_parsed, "cmp")
			}

			b = eat_byte(&index, data)
			instruction.bytes[1] = b
			if instruction.bytes[0] & W == W {
				instruction.bytes[2] = eat_byte(&index, data)
				add_to_result(
					&parsed,
					&index_parsed,
					fmt.aprintf(
						" ax, %v",
						i16(instruction.bytes[1]) + (i16(instruction.bytes[2]) << 8),
					),
				)
			} else {
				add_to_result(
					&parsed,
					&index_parsed,
					fmt.aprintf(" al, %v", i8(instruction.bytes[1])),
				)
			}
			add_to_result(&parsed, &index_parsed, "\n")
			debug_log("\n")
			instruction = init_instruction()
		}
	}
	debug_log("\n")
	return result_to_string(parsed)
}


@(test)
test_mov_register_to_register_word :: proc(t: ^testing.T) {
	data: []u8 = {0x89, 0xde}
	result := parse(&data)
	testing.expect_value(t, "mov si, bx\n", result)
}

@(test)
test_mov_register_to_register :: proc(t: ^testing.T) {
	data: []u8 = {0x88, 0xc6}
	result := parse(&data)
	testing.expect_value(t, "mov dh, al\n", result)
}

@(test)
test_mov_8bit_immediate_to_register_1 :: proc(t: ^testing.T) {
	data: []u8 = {0xb1, 0x0c}
	result := parse(&data)
	testing.expect_value(t, "mov cl, 12\n", result)
}

@(test)
test_mov_8bit_immediate_to_register_2 :: proc(t: ^testing.T) {
	data: []u8 = {0xb5, 0xf4}
	result := parse(&data)
	testing.expect_value(t, "mov ch, 244\n", result)
}

@(test)
test_mov_16bit_immediate_to_register_1 :: proc(t: ^testing.T) {
	data: []u8 = {0xb9, 0xc, 0x0}
	result := parse(&data)
	testing.expect_value(t, "mov cx, 12\n", result)
}

@(test)
test_mov_16bit_immediate_to_register_2 :: proc(t: ^testing.T) {
	data: []u8 = {0xba, 0x94, 0xf0}
	result := parse(&data)
	testing.expect_value(t, "mov dx, 61588\n", result)
}

@(test)
test_mov_source_address_calculation_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x8a, 0x0}
	result := parse(&data)
	testing.expect_value(t, "mov al, [bx + si]\n", result)
}

@(test)
test_mov_source_address_calculation_2 :: proc(t: ^testing.T) {
	data: []u8 = {0x8b, 0x56, 0x0}
	result := parse(&data)
	testing.expect_value(t, "mov dx, [bp]\n", result)
}

@(test)
test_mov_source_address_calculation_plus_8_disp :: proc(t: ^testing.T) {
	data: []u8 = {0x8a, 0x60, 0x04}
	result := parse(&data)
	testing.expect_value(t, "mov ah, [bx + si + 4]\n", result)
}

@(test)
test_mov_source_address_calculation_plus_16_disp :: proc(t: ^testing.T) {
	data: []u8 = {0x8a, 0x80, 0x87, 0x13}
	result := parse(&data)
	testing.expect_value(t, "mov al, [bx + si + 4999]\n", result)
}

@(test)
test_mov_dest_address_calculation_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x89, 0x09}
	result := parse(&data)
	testing.expect_value(t, "mov [bx + di], cx\n", result)
}

@(test)
test_mov_dest_address_calculation_2 :: proc(t: ^testing.T) {
	data: []u8 = {0x88, 0x6e, 0x00}
	result := parse(&data)
	testing.expect_value(t, "mov [bp], ch\n", result)
}

@(test)
test_add_register_to_register_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x03, 0x18}
	result := parse(&data)
	testing.expect_value(t, "add bx, [bx + si]\n", result)
}

@(test)
test_add_register_to_register_2 :: proc(t: ^testing.T) {
	data: []u8 = {0x03, 0x5e, 0x00}
	result := parse(&data)
	testing.expect_value(t, "add bx, [bp]\n", result)
}

@(test)
test_add_immediate_to_register_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x83, 0xc6, 0x02}
	result := parse(&data)
	testing.expect_value(t, "add si, 2\n", result)
}

@(test)
test_add_immediate_to_register_2 :: proc(t: ^testing.T) {
	data: []u8 = {0x83, 0xc5, 0x02}
	result := parse(&data)
	testing.expect_value(t, "add bp, 2\n", result)
}

@(test)
test_add_register_to_register_displacement_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x03, 0x5e, 0x00}
	result := parse(&data)
	testing.expect_value(t, "add bx, [bp]\n", result)
}

@(test)
test_add_register_to_register_displacement_2 :: proc(t: ^testing.T) {
	data: []u8 = {0x03, 0x4f, 0x02}
	result := parse(&data)
	testing.expect_value(t, "add cx, [bx + 2]\n", result)
}

@(test)
test_add_register_to_register_dest_1 :: proc(t: ^testing.T) {
	data: []u8 = {0x01, 0x18}
	result := parse(&data)
	testing.expect_value(t, "add [bx + si], bx\n", result)
}

@(test)
test_add_byte_to_reg :: proc(t: ^testing.T) {
	data: []u8 = {0x80, 0x07, 0x22}
	result := parse(&data)
	testing.expect_value(t, "add byte [bx], 34\n", result)
}

@(test)
test_add_word_to_xreg :: proc(t: ^testing.T) {
	data: []u8 = {0x83, 0x82, 0xE8, 0x03, 0x1d}
	result := parse(&data)
	testing.expect_value(t, "add word [bp + si + 1000], 29\n", result)
}

@(test)
test_add_immediate_to_acc :: proc(t: ^testing.T) {
	data: []u8 = {0x05, 0xe8, 0x03}
	result := parse(&data)
	testing.expect_value(t, "add ax, 1000\n", result)
}

@(test)
test_add_sign :: proc(t: ^testing.T) {
	data: []u8 = {0x04, 0xe2}
	result := parse(&data)
	testing.expect_value(t, "add al, -30\n", result)
}

@(test)
test_sub :: proc(t: ^testing.T) {
	data: []u8 = {0x2b, 0x18}
	result := parse(&data)
	testing.expect_value(t, "sub bx, [bx + si]\n", result)
}

@(test)
test_sub_word :: proc(t: ^testing.T) {
	data: []u8 = {0x83, 0x29, 0x1d}
	result := parse(&data)
	testing.expect_value(t, "sub word [bx + di], 29\n", result)
}

@(test)
test_sub_imm_word :: proc(t: ^testing.T) {
	data: []u8 = {0x2d, 0xe8, 0x3}
	result := parse(&data)
	testing.expect_value(t, "sub ax, 1000\n", result)
}

@(test)
test_sub_imm_neg :: proc(t: ^testing.T) {
	data: []u8 = {0x2c, 0xe2}
	result := parse(&data)
	testing.expect_value(t, "sub al, -30\n", result)
}

@(test)
test_cmp_dest_word :: proc(t: ^testing.T) {
	data: []u8 = {0x83, 0x3e, 0xe2, 0x12, 0x1d}
	result := parse(&data)
	testing.expect_value(t, "cmp word [4834], 29\n", result)
}
