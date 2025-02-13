class_name Bullet
extends HitBox

const SPEED = 7
var direction: Vector2
var color: Color


func _init() -> void:
	collision_layer = 2 + 16
	collision_mask = 4 + 16


func _ready() -> void:
	var sprite: Sprite2D = $Sprite2D
	if direction.x == -1:
		sprite.rotation *= -1
	if color:
		sprite.self_modulate = color
		
	connect("area_entered", _on_area_entered)


# when parry successfully done, flip the bullet in the other direction
func parry():
	direction.x *= -1
	$Sprite2D.rotation *= -1	


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED


# explode bullet if colliding with another bullet
func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		ExplosionSpawner.spawn((global_position + area.global_position) / 2)
		queue_free()


func _on_timer_timeout() -> void:
	fade_out()


func fade_out():
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", $Sprite2D.scale * 0.5, 0.25)
	tween.tween_property($Sprite2D, "modulate", Color.TRANSPARENT, 0.25)
	tween.tween_callback(queue_free)
