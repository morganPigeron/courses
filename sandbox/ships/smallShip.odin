package ships

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

small_ship :: struct {
	body:       PhysicBody,
	active:     bool,
	health:     u8,
	speed:      f32,
	debug_text: [100]byte,
}

draw_small_ship :: proc(ship: small_ship) {
	rl.DrawCubeV(ship.body.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLUE)
	rl.DrawCubeWiresV(ship.body.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLACK)
}

draw_small_ship_2d :: proc(ship: ^small_ship, camera: rl.Camera3D) {
	gui_position := rl.Vector3 {
		ship.body.position.x,
		ship.body.position.y + 0.2,
		ship.body.position.z,
	}
	ship_screen_position := rl.GetWorldToScreen(gui_position, camera)
	text := strings.unsafe_string_to_cstring(
		fmt.bprintf(
			ship.debug_text[:],
			"x:%.2f, y:%.2f, z:%.2f \x00", //null byte at the end mandatory 
			ship.body.position.x,
			ship.body.position.y,
			ship.body.position.z,
		),
	)
	font_size: i32 = 2
	text_size := rl.MeasureText(text, font_size)

	rl.DrawText(
		text,
		i32(ship_screen_position.x) - text_size / 2,
		i32(ship_screen_position.y),
		font_size,
		rl.BLACK,
	)
}

draw_debug_small_ships :: proc(ship: small_ship) {
	rl.DrawLine3D(ship.body.position, ship.body.position + ship.body.speed, rl.GREEN)
}

init_small_ship :: proc(ship: ^small_ship) {
	ship.body.position.z = 10
	ship.body.position.x = 1
	ship.body.position.y = 1
	ship.body.speed.z = -0.1
	ship.speed = 0.05
}

update_small_ship :: proc(ship: ^small_ship) {
	if ship.body.position.z <= -10 {
		ship.body.position.z = 10
	} else {
		ship.body.speed.z = ship.speed
		update(&ship.body)
	}
}
