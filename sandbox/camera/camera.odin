package camera

import rl "vendor:raylib"

draw_debug_cam :: proc(camera: rl.Camera) {
	//draw camera axis
	rl.DrawSphere(camera.target, 0.1, rl.VIOLET)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x + 1, camera.target.y, camera.target.z},
		rl.RED,
	)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x, camera.target.y + 1, camera.target.z},
		rl.BLUE,
	)
	rl.DrawLine3D(
		camera.target,
		rl.Vector3{camera.target.x, camera.target.y, camera.target.z + 1},
		rl.GREEN,
	)
}

draw_debug_cam_2d :: proc(camera: rl.Camera3D) {
	rl.
}
