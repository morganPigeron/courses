package main

import "core:log"
import rl "vendor:raylib"

// TODO
// 3D empty scene with gui button that follow camera 

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(1280, 720, "sandbox")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	camera := rl.Camera{}
	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	for !rl.WindowShouldClose() {

		rl.UpdateCamera(&camera, rl.CameraMode.THIRD_PERSON)
		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.RAYWHITE)

			{
				rl.BeginMode3D(camera)
				defer rl.EndMode3D()

				rl.DrawCubeV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.RED)
				rl.DrawCubeWiresV(rl.Vector3{0, 0, 0}, rl.Vector3{2, 2, 2}, rl.BLACK)
				rl.DrawGrid(10, 1)
			}


			rl.DrawFPS(10, 10)
			rl.DrawText("test", 40, 40, 40, rl.GREEN)
		}
	}
}
