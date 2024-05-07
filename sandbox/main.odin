package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

init_ship :: proc(ships: []small_ship) {
	for &ship in ships {
		ship.position.z = 10
		ship.position.x = f32(rl.GetRandomValue(-5000, 5000)) / 1000
		ship.position.y = f32(rl.GetRandomValue(-5000, 5000)) / 1000
		ship.speed = f32(rl.GetRandomValue(1, 100)) / 1000
	}
}

camera := rl.Camera{}

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

	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	enemy: [1000]small_ship
	init_ship(enemy[:])

	//rl.DisableCursor()
	for !rl.WindowShouldClose() {

		rl.UpdateCamera(&camera, rl.CameraMode.THIRD_PERSON)
		handle_input(&camera)

		update_small_ships(enemy[:])
		targets := check_collision_from(rl.Vector3{0, 0, 0}, enemy[:], 3)
		defer delete(targets)
		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.RAYWHITE)
			{
				rl.BeginMode3D(camera)
				defer rl.EndMode3D()

				rl.DrawGrid(10, 1)
				draw_main_ship()
				draw_small_ship(enemy[:])
				draw_debug_cam(camera)
				draw_debug_small_ships(enemy[:])
				draw_targets(targets)
			}

			draw_small_ship_2d(enemy[:])
			rl.DrawFPS(10, 10)
			rl.DrawText("test", 40, 40, 40, rl.GREEN)
		}
	}
}

draw_debug_cam :: proc(camera: rl.Camera) {
	//draw camera axis
	rl.DrawSphere(camera.target, 0.1, rl.VIOLET)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x + 1, camera.target.y, camera.target.z},
		rl.RED,
	)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x, camera.target.y + 1, camera.target.z},
		rl.BLUE,
	)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x, camera.target.y, camera.target.z + 1},
		rl.GREEN,
	)
}

handle_input :: proc(camera: ^rl.Camera3D) {
	cam_to_target := camera.target - camera.position
    norm_cam_to_target := rl.Vector3Normalize(cam_to_target)
	camera.position += norm_cam_to_target * 0.01 * rl.GetMouseWheelMove()
    
    if rl.IsKeyDown(rl.KeyboardKey.PAGE_UP) {
        camera.position += norm_cam_to_target * 0.1
    } else if rl.IsKeyDown(rl.KeyboardKey.PAGE_DOWN) {
        camera.position -= norm_cam_to_target * 0.1
    }
}

draw_main_ship :: proc() {
	rl.DrawCubeV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.RED)
	rl.DrawCubeWiresV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.BLACK)
}

draw_targets :: proc(ships: []small_ship) {
	for ship in ships {
		rl.DrawLine3D(rl.Vector3{}, ship.position, rl.RED)
	}
}

check_collision_from :: proc(from: rl.Vector3, to: []small_ship, distance: f32) -> []small_ship {
	result: [dynamic]small_ship
	for ship in to {
		if rl.Vector3Distance(ship.position, from) < distance {
			append(&result, ship)
		}
	}
	return result[:]
}
