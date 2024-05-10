package ships

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

cannon_target :: struct {
	available: bool,
	position:  rl.Vector3,
}

auto_cannon :: struct {
	position:    rl.Vector3,
	orientation: rl.Vector3,
	active:      bool,
	health:      u8,
	target:      cannon_target,
	debug_text:  [100]byte,
}

init_auto_cannon :: proc(cannon: ^auto_cannon, position: rl.Vector3, orientation: rl.Vector3) {
	cannon.position = position
	cannon.active = true
	cannon.health = 100
	cannon.target = cannon_target{false, rl.Vector3{}}
}

update_auto_cannon :: proc(cannon: ^auto_cannon, positon: rl.Vector3, orientation: rl.Vector3) {
	cannon.position = positon
	cannon.orientation = orientation
}

draw_auto_cannon :: proc(cannon: auto_cannon) {
	rl.DrawSphere(cannon.position, 0.1, rl.RED)
}

draw_auto_cannon_2d :: proc(cannon: ^auto_cannon, camera: rl.Camera) {
	gui_position := rl.Vector3{cannon.position.x, cannon.position.y + 0.2, cannon.position.z}
	cannon_screen_position := rl.GetWorldToScreen(gui_position, camera)
	text := strings.unsafe_string_to_cstring(
		fmt.bprintf(
			cannon.debug_text[:],
			"x:%.2f, y:%.2f, z:%.2f \x00", //null byte at the end mandatory 
			cannon.position.x,
			cannon.position.y,
			cannon.position.z,
		),
	)
	font_size: i32 = 2
	text_size := rl.MeasureText(text, font_size)

	rl.DrawText(
		text,
		i32(cannon_screen_position.x) - text_size / 2,
		i32(cannon_screen_position.y),
		font_size,
		rl.BLACK,
	)
}
