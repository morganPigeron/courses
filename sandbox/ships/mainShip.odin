package ships

import "../projectile"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

main_ship :: struct {
	body:          PhysicBody,
	active:        bool,
	health:        u8,
	speed:         f32,
	debug_text:    [100]byte,
	cannons:       [10]auto_cannon,
	cannons_count: int,
	targets:       [10]cannon_target,
	targets_count: int,
}

set_main_ship_targets :: proc(ship: ^main_ship, targets: []small_ship) {
	for i in 0 ..< len(targets[:]) {
		if i >= len(ship.targets) {
			ship.targets_count = len(ship.targets)
			return
		}
		ship.targets[i] = cannon_target{true, targets[i].body}
	}
	ship.targets_count = len(targets[:])
}

init_main_ship :: proc(ship: ^main_ship) {
	ship.active = true
	ship.health = 100
	ship.speed = 1
	ship.targets_count = 0
	cannon := auto_cannon{}
	cannon.position = ship.body.position + rl.Vector3{2, 0, 0}
	init(&cannon)
	ship.cannons[0] = cannon
	ship.cannons_count = 1
}

update_main_ship :: proc(ship: ^main_ship) {
	for &cannon in ship.cannons[:ship.cannons_count] {
		cannon.position = ship.body.position + rl.Vector3{0.5, 0, 0}
		if ship.targets_count > 0 {
			cannon.target = cannon_target{true, ship.targets[0].body}
		} else {
			cannon.target.available = false
		}
	}
	update(&ship.body)
}

draw_main_ship :: proc(ship: main_ship) {
	rl.DrawCubeV(ship.body.position, rl.Vector3{1, 0.5, 2}, rl.PURPLE)
	rl.DrawCubeWiresV(ship.body.position, rl.Vector3{1, 0.5, 2}, rl.BLACK)
}

draw_main_ship_2d :: proc(ship: ^main_ship, camera: rl.Camera3D) {
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
