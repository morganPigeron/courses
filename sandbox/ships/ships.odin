package ships
import rl "vendor:raylib"

AllShips :: struct {
	small_ships:  [dynamic]small_ship,
	main_ships:   [dynamic]main_ship,
	auto_cannons: [dynamic]auto_cannon,
}

init_all_ships :: proc(all: ^AllShips) {
	all.auto_cannons = make([dynamic]auto_cannon, 0, 100)
	all.main_ships = make([dynamic]main_ship, 0, 100)
	all.small_ships = make([dynamic]small_ship, 0, 100)
}

delete_all_ships :: proc(all: ^AllShips) {
	delete(all.auto_cannons)
	delete(all.main_ships)
	delete(all.small_ships)
}

update_all_ships :: proc(all: ^AllShips) {
	for &ship in all.main_ships {
		update(&ship)
	}
	for &ship in all.small_ships {
		update(&ship)
	}
}

draw_all_ships :: proc(all: AllShips) {
	for ship in all.auto_cannons {
		draw(ship)
	}
	for ship in all.main_ships {
		draw(ship)
	}
	for ship in all.small_ships {
		draw(ship)
	}
}

draw_all_ships_2d :: proc(all: ^AllShips, cam: rl.Camera3D) {
	for &ship in all.auto_cannons {
		draw_2d(&ship, cam)
	}
	for &ship in all.main_ships {
		draw_2d(&ship, cam)
	}
	for &ship in all.small_ships {
		draw_2d(&ship, cam)
	}
}

ship :: union {
	small_ship,
	main_ship,
	auto_cannon,
}

init :: proc {
	init_main_ship,
	init_small_ship,
	init_auto_cannon,
}

update :: proc {
	update_all_ships,
	update_main_ship,
	update_small_ship,
	update_auto_cannon,
	update_body,
}

draw :: proc {
	draw_all_ships,
	draw_main_ship,
	draw_small_ship,
	draw_auto_cannon,
}

draw_2d :: proc {
	draw_all_ships_2d,
	draw_main_ship_2d,
	draw_small_ship_2d,
	draw_auto_cannon_2d,
}
