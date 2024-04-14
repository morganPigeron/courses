package main

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
}

test_proc :: proc(v: Vector3) -> TestStruct {
	t := transmute(TestStruct)v
	return t
}
