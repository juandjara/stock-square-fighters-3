class_name Bullet
extends HitBox

const SPEED = 7
var direction: Vector2
var color: Color

var explosion_scene = preload("res://scenes/explosion.tscn")

func _init() -> void:
	collision_layer = 2 + 16
	collision_mask = 4 + 16

func _ready() -> void:
	var sprite: Sprite2D = $Sprite2D
	if direction.x == -1:
		sprite.rotation *= -1
	if color:
		sprite.self_modulate = color
	
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED


func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	spawn_explosion(area.global_position)
	queue_free()


func spawn_explosion(pos: Vector2):
	var explosion: CPUParticles2D = explosion_scene.instantiate()
	explosion.global_position = (global_position + pos) / 2
	explosion.emitting = true
	explosion.lifetime = randf_range(0.3, 0.6)

	$/root/world.add_child(explosion)
	
	await get_tree().create_timer(1).timeout
	
	explosion.queue_free()
