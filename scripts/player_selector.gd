class_name PlayerSelector
extends Control

var index = 0

# character data array assigned from the inspector
@export var characters: Array[CharacterData] = []

@export var top_label: String = "Player 1"
@export var button_icon: Texture2D

@onready var selector = $OptionButton as OptionButton

signal character_selected(data: CharacterData)


func _ready() -> void:
	init_option_button()
	update_selection(index)
	
	$top_label.text = top_label
	if button_icon:
		$next.icon = button_icon
		$prev.icon = button_icon


func init_option_button():
	selector.clear()
	for _index in range(0, characters.size()):
		var character = characters[_index]
		selector.add_item(character.name.to_upper(), _index)


func update_stats_color(color: Color):
	var b1 = $stats/attack as Button
	if b1:
		b1.add_theme_color_override("font_color", color)
		b1.add_theme_color_override("icon_normal_color", color)
	var b2 = $stats/defense as Button
	if b2:
		b2.add_theme_color_override("font_color", color)
		b2.add_theme_color_override("icon_normal_color", color)
	var b3 = $stats/energy as Button
	if b3:
		b3.add_theme_color_override("font_color", color)
		b3.add_theme_color_override("icon_normal_color", color)


func update_stats(data: CharacterData):
	var b1 = $stats/attack as Button
	if b1:
		b1.text = str(data.attack)
	var b2 = $stats/defense as Button
	if b2:
		b2.text = str(data.defense)
	var b3 = $stats/energy as Button
	if b3:
		b3.text = str(data.energy)


func update_character():
	var character = characters[index]
	if character:
		$avatar.texture = character.sprite
		update_stats_color(character.energy_color)
		update_stats(character)
		character_selected.emit(character)


func update_selection(_index: int):
	selector.select(_index)
	selector.emit_signal("item_selected", _index)


func _on_prev_pressed():
	var new_index = index - 1
	if new_index < 0:
		new_index = characters.size() - 1
	update_selection(new_index)


func _on_next_pressed():
	var new_index = index + 1
	if new_index >= characters.size():
		new_index = 0
	update_selection(new_index)


func _on_item_selected(_index: int) -> void:
	index = _index
	update_character()
