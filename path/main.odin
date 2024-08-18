package main

import "core:fmt"
import "core:log"
import rl "vendor:raylib"


main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(1220, 720, "path")
	defer rl.CloseWindow()

	camera := rl.Camera2D{}
	camera.zoom = 1

	grid := new_grid(10, {0, 0}, {1220, 720})

	for !rl.WindowShouldClose() {

		mouse := rl.GetMousePosition()

		cell, ok := getCellByCoord(grid, mouse)
		if ok {
			cell.isActive = true
		}

		if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
			clearGrid(&grid)
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.GRAY)

			{
				rl.BeginMode2D(camera)
				defer rl.EndMode2D()

				draw2dGrid(grid)

			}
		}
	}
}
