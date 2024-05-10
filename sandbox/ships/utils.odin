package ships

import rl "vendor:raylib"

draw_targets :: proc(ships: []small_ship) {
	for ship in ships {
		rl.DrawLine3D(rl.Vector3{}, ship.position, rl.RED)
	}
}

check_collision_from :: proc(from: rl.Vector3, to: []small_ship, distance: f32) -> []small_ship {
	result: [dynamic]small_ship
	for ship in to {
		if rl.Vector3Distance(ship.position, from) < distance {
			append(&result, ship)
		}
	}
	return result[:]
}
