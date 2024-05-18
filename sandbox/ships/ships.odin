package ships
import rl "vendor:raylib"
ship :: union {
	small_ship,
	main_ship,
	auto_cannon,
}

init :: proc {
	init_ship,
	init_main_ship,
	init_small_ship,
	init_auto_cannon,
}

init_ship :: proc(ship: ^ship) {
	switch &s in ship {
	case small_ship:
		init_small_ship(&s)
	case main_ship:
		init_main_ship(&s)
	case auto_cannon:
		init_auto_cannon(&s)
	}
}

update :: proc {
	update_ship,
	update_main_ship,
	update_small_ship,
	update_auto_cannon,
	update_body,
}

update_ship :: proc(ship: ^ship) {
	switch &s in ship {
	case small_ship:
		update_small_ship(&s)
	case main_ship:
		update_main_ship(&s)
	case auto_cannon:
		update_auto_cannon(&s)
	}
}

draw :: proc {
	draw_ship,
	draw_main_ship,
	draw_small_ship,
	draw_auto_cannon,
}

draw_ship :: proc(ship: ^ship) {
	switch s in ship {
	case small_ship:
		draw_small_ship(s)
	case main_ship:
		draw_main_ship(s)
	case auto_cannon:
		draw_auto_cannon(s)
	}
}

draw_2d :: proc {
	draw_ship_2d,
	draw_main_ship_2d,
	draw_small_ship_2d,
	draw_auto_cannon_2d,
}

draw_ship_2d :: proc(ship: ^ship, camera: rl.Camera3D) {
	switch &s in ship {
	case small_ship:
		draw_small_ship_2d(&s, camera)
	case main_ship:
		draw_main_ship_2d(&s, camera)
	case auto_cannon:
		draw_auto_cannon_2d(&s, camera)
	}
}
