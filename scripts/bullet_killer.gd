extends Area2D

func _init() -> void:
	collision_mask = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Bullet):
	if area == null:
		return
	
	area.queue_free()
