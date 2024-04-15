package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:strings"

import rl "vendor:raylib"

HsvColor :: struct {
	hue:        f32,
	saturation: f32,
	value:      f32,
}

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(640, 480, "seam carving")

	image_path: cstring = "Broadway_tower_edit.png"

	image := rl.LoadImage(image_path)
	defer rl.UnloadImage(image)
	rl.ImageFormat(&image, rl.PixelFormat.UNCOMPRESSED_R8G8B8A8)

	rl.SetWindowSize(image.width * 2, image.height)

	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)

	image_copy := rl.ImageCopy(image)
	defer rl.UnloadImage(image_copy)

	new_texture := rl.LoadTextureFromImage(image_copy)
	defer rl.UnloadTexture(new_texture)

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()

		image_size: int = int(image.height * image.width)

		colors := rl.LoadImageColors(image)
		defer rl.UnloadImageColors(colors)

		for i in 0 ..< image_size {
			c := colors[i]
			r := c[0]
			g := c[1]
			b := c[2]
			result: u8 = u8(math.sqrt_f16(f16(r * r + g * g + b * b)) * 5)
			if (result > 255) {
				result = 255
			}

			colors[i][0] = result
			colors[i][1] = result
			colors[i][2] = result
			colors[i][3] = 255
		}

		rl.UpdateTexture(new_texture, colors)

		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.DrawTexture(new_texture, image.width, 0, rl.WHITE)
	}

}
