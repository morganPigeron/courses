package camera
import rl "vendor:raylib"

handle_input :: proc(camera: ^rl.Camera3D) {
	cam_to_target := camera.target - camera.position
	norm_cam_to_target := rl.Vector3Normalize(cam_to_target)
	camera.position += norm_cam_to_target * 0.01 * rl.GetMouseWheelMove()

	if rl.IsKeyDown(rl.KeyboardKey.PAGE_UP) {
		camera.position += norm_cam_to_target * 0.1
	} else if rl.IsKeyDown(rl.KeyboardKey.PAGE_DOWN) {
		camera.position -= norm_cam_to_target * 0.1
	}
}
