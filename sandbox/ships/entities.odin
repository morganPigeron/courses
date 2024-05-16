package ships

import rl "vendor:raylib"

PhysicBody :: struct {
    position: rl.Vector3,
    speed: rl.Vector3,
} 

update_entity :: proc (body: ^PhysicBody) {
    body.position += body.speed
}
