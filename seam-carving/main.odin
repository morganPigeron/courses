package main

import "core:fmt"
import "core:log"
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

	image_copy := rl.ImageCopy(image)
	defer rl.UnloadImage(image_copy)

	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)

	new_texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(new_texture)

	control_buffer := make(
		[dynamic]rl.Color,
		image.height * image.width,
		image.height * image.width * 2, // twice capacity in case of scale up
	)
	defer delete(control_buffer)

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()

		image_size: int = int(image.height * image.width)

		if len(control_buffer) < image_size {
			resize(&control_buffer, image_size)
		}

		colors := rl.LoadImageColors(image)
		defer rl.UnloadImageColors(colors)

		for i in 0 ..< image_size {
			c := colors[i]
			r := c[0]
			g := c[1]
			b := c[2]
			result: u8 = r * r + g * g + b * b % 255
			control_buffer[i] = rl.Color{result, result, result, 255} //transmute(HsvColor)rl.ColorToHSV(colors[i])
		}

		//rl.UpdateTexture(new_texture, rawptr(&control_buffer))

		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.DrawTexture(new_texture, image.width, 0, rl.WHITE)
	}

}
