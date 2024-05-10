package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

import "./scenes"
import "./ships"

main :: proc() {
	context.logger = log.create_console_logger()

	//Tracking allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		leaks := false
		for key, value in a.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
			leaks = true
		}
		mem.tracking_allocator_clear(a)
		return leaks
	}
	defer reset_tracking_allocator(&tracking_allocator)
	//Tracking allocator end

	rl.InitWindow(1280, 720, "sandbox")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	data_test := scenes.scene_convoy_data{}
	scenes.scene_setup(&data_test)
	//rl.DisableCursor()
	for !rl.WindowShouldClose() {
		scenes.scene_loop(&data_test)
	}
}
