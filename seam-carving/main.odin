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

	rl.SetWindowSize(image.width, image.height)

	image_copy := rl.ImageCopy(image)
	defer rl.UnloadImage(image_copy)

	texture := rl.LoadTextureFromImage(image)
	defer rl.UnloadTexture(texture)

	hsv_image_buffer: [dynamic]HsvColor = make(
		[dynamic]HsvColor,
		0,
		image.height * image.width * 8,
	)
	defer delete(hsv_image_buffer)

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()

		image_size: int = int(image.height * image.width) * 8

		// resize hsv colors to match image size 
		if cap(hsv_image_buffer) < image_size {
			reserve(&hsv_image_buffer, image_size)
		}

		colors := rl.LoadImageColors(image)
		for i in 0 ..< image_size {
			hsv_image_buffer[i] = transmute(HsvColor)rl.ColorToHSV(colors[i])
		}

		rl.DrawTexture(texture, 0, 0, rl.WHITE)

	}

}
