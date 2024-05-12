package ships

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

main_ship :: struct {
	position:      rl.Vector3,
	active:        bool,
	health:        u8,
	speed:         f32,
	speed_vector:  rl.Vector3,
	debug_text:    [100]byte,
	cannons:       [10]auto_cannon,
	cannons_count: int,
	targets:       [10]cannon_target,
}

set_main_ship_targets :: proc(ship: ^main_ship, targets: []small_ship) {
	for i in 0 ..< len(targets[:]) {
		if i >= len(ship.targets) {
			return
		}
		ship.targets[i] = cannon_target{true, targets[i].position, targets[i].speed_vector}
	}
}

init_main_ship :: proc(ship: ^main_ship, position: rl.Vector3) {
	ship.position = position
	ship.active = true
	ship.health = 100
	ship.speed = 1
	cannon := auto_cannon{}
	init(&cannon, ship.position + rl.Vector3{2, 0, 0}, rl.Vector3{1, 0, 0})
	ship.cannons[0] = cannon
	ship.cannons_count = 1
}

update_main_ship :: proc(ship: ^main_ship) {
	for &cannon in ship.cannons[:ship.cannons_count] {
		if len(ship.targets) > 0 {
			update(
				&cannon,
				ship.position + rl.Vector3{0.5, 0, 0},
				cannon_target{true, ship.targets[0].position, ship.targets[0].speed_vector},
			)
		} else {
			update(
				&cannon,
				ship.position + rl.Vector3{0.5, 0, 0},
				cannon_target{false, rl.Vector3{}, rl.Vector3{}},
			)
		}
	}
}

draw_main_ship :: proc(ship: main_ship) {
	rl.DrawCubeV(ship.position, rl.Vector3{1, 0.5, 2}, rl.PURPLE)
	rl.DrawCubeWiresV(ship.position, rl.Vector3{1, 0.5, 2}, rl.BLACK)
	for i in 0 ..< ship.cannons_count {
		draw(ship.cannons[i])
	}
}

draw_main_ship_2d :: proc(ship: ^main_ship, camera: rl.Camera3D) {
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
