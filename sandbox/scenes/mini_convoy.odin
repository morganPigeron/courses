package scenes

import "../camera"
import "../entities"
import "../ships"
import rl "vendor:raylib"

scene_convoy_data :: struct {
	camera:   rl.Camera3D,
	entities: entities.entityBag,
}

scene_convoy_setup :: proc(data: ^scene_convoy_data) {
	camera := rl.Camera3D{}
	camera.position = rl.Vector3{10, 10, 10}
	camera.target = rl.Vector3{0, 0, 0}
	camera.up = rl.Vector3{0, 1, 0}
	camera.fovy = 45
	camera.projection = rl.CameraProjection.PERSPECTIVE

	data.camera = camera

	data.entities = entities.create_entity_bag()

	main_ship := ships.main_ship{}
	entities.add_entity_ship(&data.entities, main_ship)

	ennemy := ships.small_ship{}
	entities.add_entity_ship(&data.entities, ennemy)

	entities.init(&data.entities)
}

scene_convoy_loop :: proc(data: ^scene_convoy_data) {
	rl.UpdateCamera(&data.camera, rl.CameraMode.THIRD_PERSON)
	camera.handle_input(&data.camera)

	entities.update(&data.entities)

	//in_ranges := ships.check_collision_from(data.entities.body.position, data.enemy[:], 5)
	//defer delete(in_ranges)

	//ships.set_main_ship_targets(&data.convoy[0], in_ranges)

	{
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		{
			rl.BeginMode3D(data.camera)
			defer rl.EndMode3D()

			//ships.draw(data.convoy[0])
			//ships.draw(data.enemy[0])

			entities.draw(&data.entities)

			rl.DrawGrid(10, 1)
			camera.draw_debug_cam(data.camera)
		}

		entities.draw_2d(&data.entities, data.camera)

		//ships.draw_2d(&data.convoy[0], data.camera)
		//ships.draw_2d(&data.enemy[0], data.camera)

		rl.DrawFPS(10, 10)
	}

}

scene_convoy_clean :: proc(data: ^scene_convoy_data) {
	entities.clear(&data.entities)
}
