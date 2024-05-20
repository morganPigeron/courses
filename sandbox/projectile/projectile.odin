package projectile

import rl "vendor:raylib"

projectile :: struct {
	position:  rl.Vector3,
	speed:     rl.Vector3,
	damage:    int,
	velocity:  f32,
	range:     f32,
	max_range: f32,
	active:    bool,
}

new_projectile :: proc(start_point: rl.Vector3, direction: rl.Vector3, range: f32) -> projectile {
	velocity: f32 = 0.1
	return projectile {
		position = start_point,
		speed = direction * velocity,
		velocity = velocity,
		damage = 1,
		range = 0,
		max_range = range,
		active = true,
	}
}

projectile_draw :: proc(projectile: projectile) {
	if projectile.active {
		rl.DrawLine3D(projectile.position, projectile.speed + projectile.position, rl.GREEN)
	}
}

projectile_update :: proc(projectile: ^projectile) {
	if !projectile.active {
		return
	} else if projectile.range >= projectile.max_range {
		projectile.active = false
		return //todo destroy it
	}
	projectile.range += projectile.velocity
	projectile.position += projectile.speed
}
