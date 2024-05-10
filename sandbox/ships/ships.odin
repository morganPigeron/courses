package ships

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
	update_main_ship,
	update_small_ship,
	update_auto_cannon,
}

draw :: proc {
	draw_main_ship,
	draw_small_ship,
	draw_auto_cannon,
}

draw_2d :: proc {
	draw_main_ship_2d,
	draw_small_ship_2d,
	draw_auto_cannon_2d,
}
