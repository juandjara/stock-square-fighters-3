extends CanvasLayer
class_name PauseMenu

@export var listen_escape: bool = true


func update_label(text: String):
	$Label.text = text

func _process(delta: float) -> void:
	if listen_escape and Input.is_action_just_pressed("ui_cancel"):
		close()

	
func close():
	visible = false
	get_tree().call_deferred("set_pause", false)


func _on_restart_pressed() -> void:
	close()
	get_tree().reload_current_scene()


func _on_continue_pressed() -> void:
	close()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	close()
	get_tree().change_scene_to_file("res://scenes/title.tscn")
