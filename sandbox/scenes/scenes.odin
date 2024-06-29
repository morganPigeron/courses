package scenes

import "../camera"
import "../ships"
import rl "vendor:raylib"

scene_init_data :: proc {
	init_scene_convoy_data,
}

scene_setup :: proc {
	scene_test_setup,
	scene_convoy_setup,
}

scene_loop :: proc {
	scene_test_loop,
	scene_convoy_loop,
}

scene_render :: proc {
    scene_convoy_render,
}

scene_clean :: proc {
	scene_convoy_clean,
}
