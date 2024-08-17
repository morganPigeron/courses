package main

import "core:log"
import rl "vendor:raylib"

WIDTH :: 1280
HEIGHT :: 720

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(WIDTH, HEIGHT, "path")
	defer rl.CloseWindow()


	camera := rl.Camera2D{}
	camera.zoom = 1

	Cell :: struct {
		isActive: bool,
	}

	Grid :: struct {
		size:  int,
		start: rl.Vector2,
		end:   rl.Vector2,
		cells: []Cell,
	}

	new_grid :: proc(size: int) -> Grid {
		start := rl.Vector2{0, 0}
		end := rl.Vector2{WIDTH, HEIGHT}
		cells_count := (end - start) / f32(size)
		cells: []Cell = make([]Cell, int(cells_count.x * cells_count.y))
		return Grid{size = size, start = {0, 0}, end = end, cells = cells}
	}

	draw2dGrid :: proc(grid: Grid) {
		for i := 0; i < int(grid.end.x); i += grid.size {
			rl.DrawLineV({f32(i), grid.start.x}, {f32(i), grid.end.y}, rl.PURPLE)
		}
		for i := 0; i < int(grid.end.y); i += grid.size {
			rl.DrawLineV({grid.start.x, f32(i)}, {grid.end.x, f32(i)}, rl.PURPLE)
		}
		for cell, i in grid.cells {
		}
	}

	grid := new_grid(10)

	for !rl.WindowShouldClose() {

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
