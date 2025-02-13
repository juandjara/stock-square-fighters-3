class_name HitBox
extends Area2D

# if using this variable, it needs to be set in the calling code before
@export var damage: int = 0

func _init() -> void:
	collision_layer = 2 # exist only in layer 2 "hitbox"
	collision_mask = 4 # collide only with layer 3 "hurtbox"


func get_damage():
	if owner and owner.has_method("get_damage"):
		return owner.get_damage()
	else:
		return damage
