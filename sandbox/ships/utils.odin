package ships

import rl "vendor:raylib"

check_collision_from :: proc(from: rl.Vector3, to: []small_ship, distance: f32) -> []small_ship {
	result: [dynamic]small_ship
	for ship in to {
		if rl.Vector3Distance(ship.position, from) < distance {
			append(&result, ship)
		}
	}
	return result[:]
}
