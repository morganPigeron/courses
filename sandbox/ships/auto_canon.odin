package ships

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

cannon_target :: struct {
	available: bool,
	body:      PhysicBody,
}

auto_cannon :: struct {
	position:    rl.Vector3,
	orientation: rl.Vector3,
	active:      bool,
	health:      u8,
	target:      cannon_target,
	debug_text:  [100]byte,
	velocity:    f32,
	max_range:   f32,
}

init_auto_cannon :: proc(cannon: ^auto_cannon) {
	cannon.active = true
	cannon.health = 100
	cannon.target = cannon_target{false, PhysicBody{}}
	cannon.max_range = 5
}

update_auto_cannon :: proc(cannon: ^auto_cannon) {
}

draw_auto_cannon :: proc(cannon: auto_cannon) {
	rl.DrawSphere(cannon.position, 0.1, rl.RED)
	if cannon.target.available == true {
		rl.DrawLine3D(cannon.position, cannon.target.body.position, rl.PURPLE)
		ahead_position := (cannon.target.body.position + (cannon.target.body.speed * 20))
		rl.DrawLine3D(cannon.position, ahead_position, rl.RED)
		to_target := ahead_position - cannon.position
		to_target_unit := rl.Vector3Normalize(to_target) * 0.2
		rl.DrawCylinderEx(
			cannon.position,
			cannon.position + to_target_unit,
			0.05,
			0.05,
			8,
			rl.BLACK,
		)
	}
}

draw_auto_cannon_2d :: proc(cannon: ^auto_cannon, camera: rl.Camera) {
	gui_position := rl.Vector3{cannon.position.x, cannon.position.y + 0.2, cannon.position.z}
	cannon_screen_position := rl.GetWorldToScreen(gui_position, camera)
	text := strings.unsafe_string_to_cstring(
		fmt.bprintf(
			cannon.debug_text[:],
			"is targeting: %v\x00", //null byte at the end mandatory 
			cannon.target.available,
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
