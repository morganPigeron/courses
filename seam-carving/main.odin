package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:strings"

import rl "vendor:raylib"

HsvColor :: struct {
	hue:        f32,
	saturation: f32,
	value:      f32,
}

State :: struct {
	last_size:   [2]u32,
	actual_size: [2]u32,
}

main :: proc() {
	context.logger = log.create_console_logger()

	rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE})
	rl.InitWindow(640, 480, "seam carving")

	image_path: cstring = "Broadway_tower_edit.png"

	image := rl.LoadImage(image_path)
	defer rl.UnloadImage(image)
	rl.ImageFormat(&image, rl.PixelFormat.UNCOMPRESSED_R8G8B8A8)

	rl.SetWindowSize(image.width * 2, image.height)

	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)

	new_image := rl.ImageCopy(image)
	new_texture := rl.LoadTextureFromImage(new_image)

	state := State{}
	state.actual_size.x = u32(image.width)
	state.actual_size.y = u32(image.height)
	state.last_size = state.actual_size

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()

		if rl.IsWindowResized() {
			state.actual_size.x = u32(rl.GetScreenWidth())
			state.actual_size.y = u32(rl.GetScreenHeight())

			rl.UnloadTexture(new_texture)

			image_size: u32 = state.last_size.x * state.last_size.y
			c: []rl.Color = slice.from_ptr(transmute(^(rl.Color))new_image.data, int(image_size))

			for i in 0 ..< image_size {
				r := c[i][0]
				g := c[i][1]
				b := c[i][2]
				result: u8 = u8(math.sqrt_f16(f16(r * r + g * g + b * b)) * 5)
				if (result > 255) {
					result = 255
				}

				c[i][0] = result
				c[i][1] = result
				c[i][2] = result
				c[i][3] = 255
			}
			// at this point we already parsed all the image pixels

			last_index := 0
			min_index := 0
			min: u8 = 255
			for i in 0 ..< state.last_size.x {
				actual := c[i][0]
				if actual < min {
					min = actual
					min_index = int(i)
				}
			}

			last_index = min_index
			log.debugf("%v", last_index)

			for j in 1 ..< state.last_size.y {

				min_index := -1
				min: u8 = 255
				for i in last_index +
					int(state.last_size.x) -
					1 ..= last_index + int(state.last_size.x) + 1 {
					actual := c[i][0]
					if actual < min {
						min = actual
						min_index = int(i)
					}
				}
				last_index = min_index
				c[min_index][0] = 255
				c[min_index][1] = 0
				c[min_index][2] = 0

			}

			new_texture = rl.LoadTextureFromImage(new_image)
			state.last_size = state.actual_size
		}

		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.DrawTexture(new_texture, image.width, 0, rl.WHITE)
	}

}
