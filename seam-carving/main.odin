package main

import "core:fmt"
import "core:log"
import "core:strings"

import rl "vendor:raylib"


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

	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.DrawTexture(texture, 0, 0, rl.WHITE)

	}


}
