class_name HitBox
extends Area2D

@export var damage: int = 10

func _init() -> void:
	collision_layer = 2 # exist only in layer 2 "hitbox"
	collision_mask = 4 # collide only with layer 3 "hurtbox"
