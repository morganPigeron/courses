package main

import "core:fmt"
import "core:os"
import "core:testing"

InstructionToken :: enum {
	ADD_RM_R_8 = 0,
	ADD_RM_R_16,
	ADD_R_RM_8,
	ADD_R_RM_16,
	ADD_AL_I_8,
	ADD_AX_I_16,
	PUSH_ES,
	POP_ES,
	OR_RM_R_8,
	OR_RM_R_16,
	OR_R_RM_8,
	OR_R_RM_16,
	OR_AL_I_8,
	OR_AX_I_16,
	PUSH_CS,
	NA1,
	ADC_RM_R_8,
	ADC_RM_R_16,
	ADC_R_RM_8,
	ADC_R_RM_16,
	ADC_AL_I_8,
	ADC_AX_I_16,
	PUSH_SS,
	POP_SS,
	SBB_RM_R_8,
	SBB_RM_R_16,
	SBB_R_RM_8,
	SBB_R_RM_16,
	SBB_AL_I_8,
	SBB_AX_I_16,
	PUSH_DS,
	POP_DS,
	AND_RM_R_8,
	AND_RM_R_16,
	AND_R_RM_8,
	AND_R_RM_16,
	AND_AL_I_8,
	AND_AX_I_16,
	ES,
	DAA,
	SUB_RM_R_8,
	SUB_RM_R_16,
	SUB_R_RM_8,
	SUB_R_RM_16,
	SUB_AL_I_8,
	SUB_AX_I_16,
	CS,
	DAS,
	XOR_RM_R_8,
	XOR_RM_R_16,
	XOR_R_RM_8,
	XOR_R_RM_16,
	XOR_AL_I_8,
	XOR_AX_I_16,
	SS,
	AAA,
	CMP_RM_R_8,
	CMP_RM_R_16,
	CMP_R_RM_8,
	CMP_R_RM_16,
	CMP_AL_I_8,
	CMP_AX_I_16,
	DS,
	AAS,
	INC_AX,
	INC_CX,
	INC_DX,
	INC_BX,
	INC_SP,
	INC_BP,
	INC_SI,
	INC_DI,
	DEC_AX,
	DEC_CX,
	DEC_DX,
	DEC_BX,
	DEC_SP,
	DEC_BP,
	DEC_SI,
	DEC_DI,
	PUSH_AX,
	PUSH_CX,
	PUSH_DX,
	PUSH_BX,
	PUSH_SP,
	PUSH_BP,
	PUSH_SI,
	PUSH_DI,
	POP_AX,
	POP_CX,
	POP_DX,
	POP_BX,
	POP_SP,
	POP_BP,
	POP_SI,
	POP_DI,
	//not used gap
	JO = 0x70,
	JNO,
	JC,
	JNC,
	JE,
	JNE,
	JBE,
	JNBE,
	JS,
	JNS,
	JP,
	JNP,
	JL,
	JNL,
	JLE,
	JNLE,
	ADD_RM_I_8,
	OR_RM_I_8,
	ADC_RM_I_8,
	XXX_RM_I_8,
	AND_RM_I_8,
	SUB_RM_I_8,
	XOR_RM_I_8,
	CMP_RM_I_8,
	ADD_RM_I_16,
	OR_RM_I_16,
	ADC_RM_I_16,
	SBB_RM_I_16,
	AND_RM_I_16,
	SUB_RM_I_16,
	XOR_RM_I_16,
	CMP_RM_I_16,
	ADD_RM_I_8_2,
	NA2,
	ADC_RM_I_8_2,
	SBB_RM_I_8_2,
	NA3,
	SUB_RM_I_8_2,
	NA4,
	CMP_RM_I_8_2,
	ADD_RM_I_16_2,
	NA5,
	ADC_RM_I_16_2,
	SBB_RM_I_16_2,
	NA6,
	SUB_RM_I_16_2,
	NA7,
	CMP_RM_I_16_2,
	TEST_RM_R_8,
	TEST_RM_R_16,
	XCHG_R_RM_8,
	XCHG_R_RM_16,
	MOV_RM_R_8 = 0x88,
	MOV_RM_R_16 = 0x89,
	MOV_R_RM_8 = 0x8A,
	MOV_R_RM_16 = 0x8B,
	MOV_RM_SEGREG = 0x8C,
	NA8,
	LEA_R_M_16,
	MOV_SEGREG_RM_16,
	NA9,
	POP_RM_16,
	NOP = 0x90,
	XCHG_AX_CX,
	XCHG_AX_DX,
	XCHG_AX_BX,
	XCHG_AX_SP,
	XCHG_AX_BP,
	XCHG_AX_SI,
	XCHG_AX_DI,
	CBW,
	CWD,
	CALL,
	WAIT,
	PUSHF,
	POPF,
	SAHF,
	LAHF,
	MOV_AL_M_8,
	MOV_AX_M_16,
	MOV_M_AL_8,
	MOV_M_AX_16,
	MOVS_D_S_8,
	MOVS_D_S_16,
	CMPS_D_S_8,
	CMPS_D_S_16,
	TEST_AL_I_8,
	TEST_AX_I_16,
	STOS_D_8,
	STOS_D_16,
	LODS_S_8,
	LODS_S_16,
	SCAS_D_8,
	SCAS_D_16,
	MOV_AL_I_8 = 0xB0,
	MOV_CL_I_8 = 0xB1,
	MOV_DL_I_8,
	MOV_BL_I_8,
	MOV_AH_I_8,
	MOV_CH_I_8,
	MOV_DH_I_8,
	MOV_BH_I_8,
	MOV_AX_I_16,
	MOV_CX_I_16,
	MOV_DX_I_16,
	MOV_BX_I_16,
	MOV_SP_I_16,
	MOV_BP_I_16,
	MOV_SI_I_16,
	MOV_DI_I_16,
	NA10,
	NA11,
	RET_I_16,
	RET,
	LES_R_M_16,
	LDS_R_M_16,
	MOV_M_I_8,
	MOV_M_I_16 = 0xC7,
	RET_I_16_2 = 0xCA,
	RET_2,
}

main :: proc() {
	if len(os.args) != 2 {
		fmt.print("Usage: decompiler <filePath>")
		return
	}
	path := os.args[1]
	data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		fmt.eprintf("cannot read file %v\n", path)
	}
	defer delete(data)

	index := 0
	for index < len(data) {
		chunk := data[index]
		index += 1
		instruction := InstructionToken(chunk)
		#partial switch instruction {

		case InstructionToken.MOV_RM_R_16:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			dest := get_register(rm, mod)
			source := get_register(reg, 0b11, true)
			fmt.printf("MOV %v, %v\n", dest, source)

		case InstructionToken.MOV_RM_R_8:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			//if mod == 1 there is 1 byte displacement 
			//if mod == 2 there is 2 bytes displacement 
			displacement: u16 = 0
			if mod == 1 {
				displacement = u16(data[index])
				index += 1
			} else if mod == 2 {
				lo := data[index]
				index += 1
				hi := data[index]
				index += 1
				displacement = (u16(hi) << 8) + u16(lo)
			}

			dest := get_register(rm, mod)
			source := get_register(reg, 0b11, false)
			fmt.printf("MOV %v, %v + %v\n", dest, source, displacement)

		case InstructionToken.MOV_R_RM_8:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			//if mod == 1 there is 1 byte displacement 
			//if mod == 2 there is 2 bytes displacement 
			displacement: u16 = 0
			if mod == 1 {
				displacement = u16(data[index])
				index += 1
			} else if mod == 2 {
				lo := data[index]
				index += 1
				hi := data[index]
				index += 1
				displacement = (u16(hi) << 8) + u16(lo)
			}
			source := get_register(rm, mod)
			dest := get_register(reg, 0b11, false)
			fmt.printf("MOV %v, %v + %v\n", dest, source, displacement)

		case InstructionToken.MOV_R_RM_16:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			//if mod == 1 there is 1 byte displacement 
			//if mod == 2 there is 2 bytes displacement 
			displacement: u16 = 0
			if mod == 1 {
				displacement = u16(data[index])
				index += 1
			} else if mod == 2 {
				lo := data[index]
				index += 1
				hi := data[index]
				index += 1
				displacement = (u16(hi) << 8) + u16(lo)
			}

			source := get_register(rm, mod)
			dest := get_register(reg, 0b11, true)
			fmt.printf("MOV %v, %v + %v\n", dest, source, displacement)

		case InstructionToken.MOV_CL_I_8:
			byte2 := data[index]
			index += 1
			dest := Register.CL
			source := byte2
			fmt.printf("MOV %v, %v\n", dest, source)

		case InstructionToken.MOV_CH_I_8:
			byte2 := data[index]
			index += 1
			dest := Register.CH
			source := byte2
			fmt.printf("MOV %v, %v\n", dest, source)

		case InstructionToken.MOV_CX_I_16:
			byte2 := data[index]
			index += 1
			byte3 := data[index]
			index += 1
			dest := Register.CX
			source := (u16(byte3) << 8) + u16(byte2)
			fmt.printf("MOV %v, %v\n", dest, source)

		case InstructionToken.MOV_DX_I_16:
			byte2 := data[index]
			index += 1
			byte3 := data[index]
			index += 1
			dest := Register.DX
			source := (u16(byte3) << 8) + u16(byte2)
			fmt.printf("MOV %v, %v\n", dest, source)

		case InstructionToken.ADD_R_RM_16:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			//if mod == 1 there is 1 byte displacement 
			//if mod == 2 there is 2 bytes displacement 
			displacement: u16 = 0
			if mod == 1 {
				displacement = u16(data[index])
				index += 1
			} else if mod == 2 {
				lo := data[index]
				index += 1
				hi := data[index]
				index += 1
				displacement = (u16(hi) << 8) + u16(lo)
			}

			source := get_register(rm, mod)
			dest := get_register(reg, 0b11, true)
			fmt.printf("ADD %v, %v + %v\n", dest, source, displacement)

		case InstructionToken.XXX_RM_I_8:
			byte2 := data[index]
			index += 1
			mod := parse_mod(byte2)
			reg := parse_reg(byte2)
			rm := parse_rm(byte2)

			//if mod == 1 there is 1 byte displacement 
			//if mod == 2 there is 2 bytes displacement 
			displacement: u16 = 0
			if mod == 1 {
				displacement = u16(data[index])
				index += 1
			} else if mod == 2 {
				lo := data[index]
				index += 1
				hi := data[index]
				index += 1
				displacement = (u16(hi) << 8) + u16(lo)
			}

			dest := get_register(reg, 0b11, true)
			fmt.printf("XXX %v, %v\n", dest, displacement)

		case:
			fmt.printf("chunk %X\n", chunk)
			fmt.printf("missing %v\n", instruction)
		}
	}
}

parse_reg :: proc(chunk: u8) -> u8 {
	return (chunk << 2) >> 5
}

@(test)
test_parse_reg :: proc(t: ^testing.T) {
	testing.expect_value(t, parse_reg(0xFF), 0b111)
	testing.expect_value(t, parse_reg(0b00111000), 0b111)
	testing.expect_value(t, parse_reg(0b11000111), 0)
}

parse_rm :: proc(chunk: u8) -> u8 {
	return chunk & 0b111
}

@(test)
test_parse_rm :: proc(t: ^testing.T) {
	testing.expect_value(t, parse_rm(0b111), 0b111)
	testing.expect_value(t, parse_rm(0xFF), 0b111)
	testing.expect_value(t, parse_rm(0b101), 0b101)
}

parse_mod :: proc(chunk: u8) -> u8 {
	return chunk >> 6
}

@(test)
test_parse_mod :: proc(t: ^testing.T) {
	testing.expect_value(t, parse_mod(0xF0), 3)
	testing.expect_value(t, parse_mod(0b10000000), 0b10)

}

Register :: enum {
	AL,
	AX,
	CL,
	CX,
	DL,
	DX,
	BL,
	BX,
	AH,
	SP,
	CH,
	BP,
	DH,
	SI,
	BH,
	DI,
	BX_SI,
	BX_SI_8,
	BX_SI_16,
	BX_DI,
	BX_DI_8,
	BX_DI_16,
	BP_SI,
	BP_SI_8,
	BP_SI_16,
	BP_DI,
	BP_DI_8,
	BP_DI_16,
	SI_8,
	SI_16,
	DI_8,
	DI_16,
	DIRECT,
	BP_8,
	BP_16,
	BX_8,
	BX_16,
}

get_register :: proc(reg: u8, mod: u8, w: bool = true) -> Register {
	Selector :: struct {
		reg: u8,
		mod: u8,
		w:   bool,
	}
	select: Selector = {reg, mod, w}

	switch select {
	case {0, 3, false}:
		return Register.AL
	case {1, 3, false}:
		return Register.CL
	case {2, 3, false}:
		return Register.DL
	case {3, 3, false}:
		return Register.BL
	case {4, 3, false}:
		return Register.AH
	case {5, 3, false}:
		return Register.CH
	case {6, 3, false}:
		return Register.DH
	case {7, 3, false}:
		return Register.BH
	case {0, 3, true}:
		return Register.AX
	case {1, 3, true}:
		return Register.CX
	case {2, 3, true}:
		return Register.DX
	case {3, 3, true}:
		return Register.BX
	case {4, 3, true}:
		return Register.SP
	case {5, 3, true}:
		return Register.BP
	case {6, 3, true}:
		return Register.SI
	case {7, 3, true}:
		return Register.DI
	case {0, 0, true}:
		return Register.BX_SI
	case {1, 0, true}:
		return Register.BX_DI
	case {2, 0, true}:
		return Register.BP_SI
	case {3, 0, true}:
		return Register.BP_DI
	case {4, 0, true}:
		return Register.SI
	case {5, 0, true}:
		return Register.DI
	case {6, 0, true}:
		return Register.DIRECT
	case {7, 0, true}:
		return Register.BX
	case {0, 1, true}:
		return Register.BX_SI_8
	case {1, 1, true}:
		return Register.BX_DI_8
	case {2, 1, true}:
		return Register.BP_SI_8
	case {3, 1, true}:
		return Register.BP_DI_8
	case {4, 1, true}:
		return Register.SI_8
	case {5, 1, true}:
		return Register.DI_8
	case {6, 1, true}:
		return Register.BP_8
	case {7, 1, true}:
		return Register.BX_8
	case {0, 2, true}:
		return Register.BX_SI_16
	case {1, 2, true}:
		return Register.BX_DI_16
	case {2, 2, true}:
		return Register.BP_SI_16
	case {3, 2, true}:
		return Register.BP_DI_16
	case {4, 2, true}:
		return Register.SI_16
	case {5, 2, true}:
		return Register.DI_16
	case {6, 2, true}:
		return Register.BP_16
	case {7, 2, true}:
		return Register.BX_16
	case:
		return Register.AX
	}
}

@(test)
test_get_register :: proc(t: ^testing.T) {
	testing.expect_value(t, get_register(0, 0, true), Register.BX_SI)
	testing.expect_value(t, get_register(0, 0), Register.BX_SI)
	testing.expect_value(t, get_register(2, 3, true), Register.DX)
	testing.expect_value(t, get_register(0b110, 0b00, true), Register.DIRECT)
}
