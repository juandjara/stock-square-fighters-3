extends Node

var explosion_scene = preload("res://scenes/explosion.tscn")

func spawn(pos: Vector2):
	var explosion: CPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = pos
	# explosion.global_position = (global_position + pos) / 2
	explosion.emitting = true
	explosion.lifetime = randf_range(0.3, 0.6)

	$/root/world.add_child(explosion)
	
	await get_tree().create_timer(1).timeout
	
	explosion.queue_free()
