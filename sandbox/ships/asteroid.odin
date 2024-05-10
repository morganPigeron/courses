package ships

import rl "vendor:raylib"

asteroid :: struct {
	position:     rl.Vector3,
	speed:        f32,
	speep_vector: rl.Vector3,
	debug_text:   [100]byte,
}
