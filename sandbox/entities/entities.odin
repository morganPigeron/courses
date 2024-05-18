package entities

import "../ships"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

entityBag :: struct {
	ships:      [dynamic]ships.ship,
	debug_text: [100]byte,
}

create_entity_bag :: proc() -> entityBag {
	return entityBag{ships = make([dynamic]ships.ship, 0, 1000)}
}

add_entity_ship :: proc(bag: ^entityBag, ship: ships.ship) {
	append(&bag.ships, ship)
}

init :: proc(bag: ^entityBag) {
	for &ship in bag.ships {
		ships.init(&ship)
	}
}

update :: proc(bag: ^entityBag) {
	for &ship in bag.ships {
		ships.update(&ship)
	}
}

draw :: proc(bag: ^entityBag) {
	for &ship in bag.ships {
		ships.draw(&ship)
	}
}

draw_2d :: proc(bag: ^entityBag, camera: rl.Camera3D) {
	for &ship in bag.ships {
		ships.draw_2d(&ship, camera)
	}
	text := strings.unsafe_string_to_cstring(
		fmt.bprintf(
			bag.debug_text[:],
			"entities count: %v \x00", //null byte at the end mandatory 
			len(bag.ships),
		),
	)
	rl.GuiLabel(rl.Rectangle{10, 10, 100, 100}, text)
}

clear :: proc(bag: ^entityBag) {
	delete(bag.ships)
}
