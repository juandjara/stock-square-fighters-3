class_name HurtBox
extends Area2D

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
	
	# check if player receiving damage can parry
	if owner.has_method("can_parry") and owner.can_parry():
		# check if hitbox damage can be parried
		if hitbox.has_method("parry"):
			hitbox.parry()
			return
	
	
	if owner.has_method("take_hit"):
		owner.take_hit(hitbox)
	
