package scenes

import "../camera"
import "../ships"
import rl "vendor:raylib"

scene_test_data :: struct {
	camera: rl.Camera3D,
	enemy:  [1000]ships.small_ship,
}

scene_test_setup :: proc(data: ^scene_test_data) {
	camera := rl.Camera3D{}
	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	data.camera = camera
	//ships.init_ship(data.enemy[:])
}

scene_test_loop :: proc(data: ^scene_test_data) {
	rl.UpdateCamera(&data.camera, rl.CameraMode.THIRD_PERSON)
	camera.handle_input(&data.camera)

	//	ships.update_small_ships(data.enemy[:])
	targets := ships.check_collision_from(rl.Vector3{0, 0, 0}, data.enemy[:], 3)
	defer delete(targets)
	{
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		{
			rl.BeginMode3D(data.camera)
			defer rl.EndMode3D()

			rl.DrawGrid(10, 1)
			//			ships.draw_main_ship()
			//ships.draw_small_ship(data.enemy[:])
			camera.draw_debug_cam(data.camera)
			//ships.draw_debug_small_ships(data.enemy[:])
			//ships.draw_targets(targets)
		}

		//ships.draw_small_ship_2d(data.enemy[:], data.camera)
		rl.DrawFPS(10, 10)
		rl.DrawText("test", 40, 40, 40, rl.GREEN)
	}
}
