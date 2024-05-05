package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"

import rl "vendor:raylib"

small_ship :: struct {
	position: rl.Vector3,
	active:   bool,
	health:   u8,
	speed:    f32,
}

init_ship :: proc(ships: []small_ship) {
	for &ship in ships {
		ship.position.z = 10
		ship.position.x = f32(rl.GetRandomValue(-5000, 5000)) / 1000
		ship.position.y = f32(rl.GetRandomValue(-5000, 5000)) / 1000
		ship.speed = f32(rl.GetRandomValue(1, 100)) / 1000
	}
}

update_enemies :: proc(ships: []small_ship) {
	for &ship in ships {
		if ship.position.z <= -10 {
			ship.position.z = 10
		} else {
			ship.position.z -= ship.speed
		}
	}
}

camera := rl.Camera{}

main :: proc() {
	context.logger = log.create_console_logger()

	//Tracking allocator
	/*
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
	*/
	//Tracking allocator end


	rl.InitWindow(1280, 720, "sandbox")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	enemy: [1000]small_ship
	init_ship(enemy[:])
	for !rl.WindowShouldClose() {

		rl.UpdateCamera(&camera, rl.CameraMode.THIRD_PERSON)
		update_enemies(enemy[:])
		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.RAYWHITE)

			{
				rl.BeginMode3D(camera)
				defer rl.EndMode3D()

				draw_main_ship()
				draw_small_ship(enemy[:])

				rl.DrawGrid(10, 1)
			}

			draw_small_ship_2d(enemy[:])

			rl.DrawFPS(10, 10)
			rl.DrawText("test", 40, 40, 40, rl.GREEN)
		}
	}
}


draw_main_ship :: proc() {
	rl.DrawCubeV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.RED)
	rl.DrawCubeWiresV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.BLACK)
}

draw_small_ship :: proc(ships: []small_ship) {
	for ship in ships {
		rl.DrawCubeV(ship.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLUE)
		rl.DrawCubeWiresV(ship.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLACK)
	}
}

draw_small_ship_2d :: proc(ships: []small_ship) {
	for ship in ships {
		gui_position := rl.Vector3{ship.position.x, ship.position.y + 0.2, ship.position.z}
		ship_screen_position := rl.GetWorldToScreen(gui_position, camera)
		text := fmt.caprintf(
			"x:%.2f, y:%.2f, z:%.2f",
			ship.position.x,
			ship.position.y,
			ship.position.z,
		)
		font_size: i32 = 2
		text_size := rl.MeasureText(text, font_size)

		rl.DrawText(
			text,
			i32(ship_screen_position.x) - text_size / 2,
			i32(ship_screen_position.y),
			font_size,
			rl.BLACK,
		)
	}
}
