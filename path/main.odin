package main

import "core:fmt"
import "core:log"
import "core:time"
import rl "vendor:raylib"

import "grid"


main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(1220, 720, "path")
	defer rl.CloseWindow()

	camera := rl.Camera2D{}
	camera.zoom = 1

	myGrid := grid.new_grid(10, {100, 100}, {1000, 600})

	stopwatch := time.Stopwatch{}
	loopMin := time.MAX_DURATION
	loopMax := time.MIN_DURATION

	for !rl.WindowShouldClose() {
		time.stopwatch_reset(&stopwatch)
		time.stopwatch_start(&stopwatch)

		mouse := rl.GetMousePosition()

		cell, ok := grid.getCellByCoord(myGrid, mouse)
		if ok {
			cell.isActive = true
		}

		if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
			grid.clearGrid(&myGrid)
		}

		{
			rl.BeginDrawing()
			defer rl.EndDrawing()

			rl.ClearBackground(rl.GRAY)

			{
				rl.BeginMode2D(camera)
				defer rl.EndMode2D()

				grid.draw2dGrid(myGrid)

			}

			time.stopwatch_stop(&stopwatch)
			loopDuration := time.stopwatch_duration(stopwatch)
			if loopDuration > loopMax {
				loopMax = loopDuration
			} else if loopDuration < loopMin {
				loopMin = loopDuration
			}

			rl.DrawText(
				fmt.ctprintf(
					"loop duration (ms): %.2f, max: %.2f, min: %.2f",
					time.duration_milliseconds(loopDuration),
					time.duration_milliseconds(loopMax),
					time.duration_milliseconds(loopMin),
				),
				10,
				10,
				10,
				rl.BLACK,
			)
		}
	}
}
