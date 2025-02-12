extends CanvasLayer


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	print("options screen not ready")
	pass # Replace with function body.


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/choose.tscn")
