extends CanvasLayer

var p1_selection: CharacterData
var p2_selection: CharacterData


func update_fight_btn():
	var disabled = p1_selection == p2_selection
	$fight.disabled = disabled


func _on_fight_pressed() -> void:
	GameState.p1_data = p1_selection
	GameState.p2_data = p2_selection
	var err = get_tree().change_scene_to_file("res://scenes/world.tscn")
	if err:
		print(err)


func _on_select_p1(data: CharacterData) -> void:
	p1_selection = data
	update_fight_btn()


func _on_select_p2(data: CharacterData) -> void:
	p2_selection = data
	update_fight_btn()
