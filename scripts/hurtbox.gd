class_name HurtBox
extends Area2D

var explosion_scene = preload("res://scenes/explosion.tscn")

func _init() -> void:
	collision_layer = 4 # exist in layer 3 "hurtbox"
	collision_mask = 2 # collide only with layer 2 "hitbox"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	
	if owner.is_ancestor_of(hitbox):
		return
	
	if owner.has_method("can_parry") and owner.can_parry():
		if hitbox is Bullet:
			hitbox.flip()
			return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.get_damage())
	
	var direction = (global_position - hitbox.global_position).normalized()
	if owner.has_method("add_pushback_force"):
		owner.add_pushback_force(direction)
	
	spawn_explosion(hitbox.global_position)
	
	if hitbox is Bullet:
		hitbox.queue_free()


func spawn_explosion(pos: Vector2):
	var explosion: CPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = (global_position + pos) / 2
	explosion.emitting = true
	explosion.lifetime = randf_range(0.3, 0.6)

	$/root/world.add_child(explosion)
	
	await get_tree().create_timer(1).timeout
	
	explosion.queue_free()
