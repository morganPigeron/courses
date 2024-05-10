package scenes

import "../camera"
import "../ships"
import rl "vendor:raylib"

scene_setup :: proc {
	scene_test_setup,
	scene_convoy_setup,
}

scene_loop :: proc {
	scene_test_loop,
	scene_convoy_loop,
}
