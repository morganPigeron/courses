package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

small_ship :: struct {
	position:     rl.Vector3,
	active:       bool,
	health:       u8,
	speed:        f32,
	speed_vector: rl.Vector3,
	debug_text:   [100]byte,
}

draw_small_ship :: proc(ships: []small_ship) {
	for ship in ships {
		rl.DrawCubeV(ship.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLUE)
		rl.DrawCubeWiresV(ship.position, rl.Vector3{0.1, 0.1, 0.1}, rl.BLACK)
	}
}

draw_small_ship_2d :: proc(ships: []small_ship) {
	for &ship in ships {
		gui_position := rl.Vector3{ship.position.x, ship.position.y + 0.2, ship.position.z}
		ship_screen_position := rl.GetWorldToScreen(gui_position, camera)
		text := strings.unsafe_string_to_cstring(
			fmt.bprintf(
				ship.debug_text[:],
				"x:%.2f, y:%.2f, z:%.2f \x00", //null byte at the end mandatory 
				ship.position.x,
				ship.position.y,
				ship.position.z,
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
}

draw_debug_small_ships :: proc(ships: []small_ship) {
	for ship in ships {
		rl.DrawLine3D(ship.position, ship.position + ship.speed_vector, rl.GREEN)
	}
}

update_small_ships :: proc(ships: []small_ship) {
	for &ship in ships {
		if ship.position.z <= -10 {
			ship.position.z = 10
		} else {
			before := ship.position
			ship.position.z -= ship.speed
			ship.speed_vector = ship.position - before
		}
	}
}
