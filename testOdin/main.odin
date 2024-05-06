package main

import "core:fmt"
import "core:log"

TestStruct :: struct {
	a: f32,
	b: f32,
	c: f32,
}

Vector3 :: struct {
	x, y, z: f32,
}

main :: proc() {
	context.logger = log.create_console_logger()

	v := Vector3{1.1, 2.2, 3.3}
	result := test_proc(v)

	log.debugf("%v", result)


	log.debugf("test string buffer reuse\n")
	buffer: [10]byte
	my_string := fmt.bprintf(buffer[:], "test %v", 1)
	log.debugf("my_string 1 = %v\n", my_string)
	my_string = fmt.bprintf(buffer[:], "test %v", 2)
	log.debugf("my_string 2 = %v\n", my_string)

}

test_proc :: proc(v: Vector3) -> TestStruct {
	t := transmute(TestStruct)v
	return t
}
