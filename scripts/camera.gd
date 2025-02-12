extends Camera2D

@export var zoom_factor: float = 800
@export var min_zoom: float = 0.5

@export var zoom_offset = 0.2

var stars: Array[Player] = []
var rect: Rect2
var viewport_rect: Rect2

var p1: Player
var p2: Player
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not viewport_rect:
		viewport_rect = get_viewport_rect()

	if not p1:
		p1 = $/root/world/player1
	if not p2:
		p2 = $/root/world/player2
	
	if not p1:
		return
	
	rect = Rect2(p1.global_position, Vector2())
	if p2:
		rect = rect.expand(p2.global_position)
	
	calc_offset()
	calc_zoom()	
	

func calc_offset():
	var center = rect.get_center()
	var view_center = viewport_rect.get_center()

	var cam_dim_x = viewport_rect.size.x / zoom.x
	var cam_dim_y = viewport_rect.size.y / zoom.y
	
	var diff_x = abs(viewport_rect.size.x - cam_dim_x)
	var diff_y = abs(viewport_rect.size.y - cam_dim_y)
	
	var max_x = view_center.x + (diff_x / 2)
	var min_x = view_center.x - (diff_x / 2)
	
	var max_y = view_center.y + (diff_y / 2)
	var min_y = view_center.y - (diff_y / 2)
	
	offset = Vector2(
		clamp(center.x, min_x, max_x),
		clamp(center.y, min_y, max_y)
	)

func calc_zoom():
	if not p1 or not p2:
		return
	
	var dist = abs(p1.global_position.x - p2.global_position.x)
	var margin = 0.4
	var new_z = (viewport_rect.size.x / dist) - margin
	var z = clamp(new_z, 1, 1.4)
	zoom = Vector2(z, z)
