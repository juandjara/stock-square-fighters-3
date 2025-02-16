extends CanvasLayer


func _ready():
	if OS.get_name() == 'Web':
		$quit.visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose.tscn")


func _on_howto_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/howto.tscn")
	
