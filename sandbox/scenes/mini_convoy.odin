package scenes

import "../camera"
import "../projectile"
import "../ships"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

scene_convoy_data :: struct {
	camera:      rl.Camera3D,
	ships:       ships.AllShips,
	projectiles: [dynamic]projectile.projectile,
	debug_text:  [250]u8,
}

init_scene_convoy_data :: proc() -> scene_convoy_data {
	return scene_convoy_data{projectiles = make([dynamic]projectile.projectile, 0, 1000)}
}

scene_convoy_setup :: proc(data: ^scene_convoy_data) {
	camera := rl.Camera3D{}
	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	data.camera = camera

	ships.init_all_ships(&data.ships)

	main_ship := ships.main_ship{}
	ships.init(&main_ship)
	append(&data.ships.main_ships, main_ship)

	ennemy := ships.small_ship{}
	ennemy.body.position.x = 2
	ennemy.body.position.y = 2
	ennemy.speed = -0.05
	append(&data.ships.small_ships, ennemy)
}

scene_convoy_loop :: proc(data: ^scene_convoy_data) {
	rl.UpdateCamera(&data.camera, rl.CameraMode.THIRD_PERSON)
	camera.handle_input(&data.camera)

	ships.update(&data.ships)

	for &main in data.ships.main_ships {
		in_ranges := ships.check_collision_from(main.body.position, data.ships.small_ships[:], 5)
		defer delete(in_ranges)
		ships.set_main_ship_targets(&main, in_ranges)

		for &cannon in main.cannons[:main.cannons_count] {
			ships.update_auto_cannon(&cannon, &data.projectiles)
		}
	}

	for &proj in data.projectiles {
		projectile.projectile_update(&proj)
	}
}

scene_convoy_render :: proc(data: ^scene_convoy_data) {
		//rl.BeginDrawing()
		//defer rl.EndDrawing()

		//rl.ClearBackground(rl.RAYWHITE)
		{
			rl.BeginMode3D(data.camera)
			defer rl.EndMode3D()

			ships.draw(data.ships)

			for &main in data.ships.main_ships {
				for &cannon in main.cannons[:main.cannons_count] {
					ships.draw(cannon)
				}
			}

			for proj in data.projectiles {
				projectile.projectile_draw(proj)
			}

			rl.DrawGrid(10, 1)
			camera.draw_debug_cam(data.camera)
		}

		ships.draw_2d(&data.ships, data.camera)

		for &main in data.ships.main_ships {
			for &cannon in main.cannons[:main.cannons_count] {
				ships.draw_2d(&cannon, data.camera)
			}
		}

		scene_convoy_debug(data)

		rl.DrawFPS(10, 10)
}

scene_convoy_clean :: proc(data: ^scene_convoy_data) {
	ships.delete_all_ships(&data.ships)
	delete(data.projectiles)
}

scene_convoy_debug :: proc(data: ^scene_convoy_data) {

	text := strings.unsafe_string_to_cstring(
		fmt.bprintf(
			data.debug_text[:],
			"projectiles count: %v\x00", //null byte at the end mandatory
			len(data.projectiles),
		),
	)

	rl.DrawText(text, 10, 10, 10, rl.BLACK)
}
