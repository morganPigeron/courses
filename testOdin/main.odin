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
	log.debugf("%v", v)

	t := transmute(TestStruct)v
	log.debugf("%v", t)
}
