extends Node2D

const MAX_FIGHT_TIME = 100
var fight_time_left = MAX_FIGHT_TIME


var player_scene = preload("res://scenes/player.tscn")


func create_p1():
	var p1 = player_scene.instantiate() as Player
	p1.global_position = Vector2(100, -100)
	p1.initial_place = "left"
	p1.name = "player1"
	add_child(p1)
	var data = GameState.p1_data
	if not data:
		data = load("res://assets/resources/albertito.tres")
	p1.init_data(data)


func create_p2():
	var vr = get_viewport_rect()
	var p2 = player_scene.instantiate() as Player
	p2.global_position = Vector2(vr.size.x - 100, -100)
	p2.initial_place = "right"
	p2.name = "player2"
	add_child(p2)
	var data = GameState.p2_data
	if not data:
		data = load("res://assets/resources/kevin.tres")
	p2.init_data(data)


func _ready() -> void:
	create_p1()
	create_p2()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var menu: PauseMenu = $/root/world/pause_menu
		if menu:
			menu.visible = true
			get_tree().call_deferred("set_pause", true)

func update_time_label():
	var label = $GUI/FightTime/FightTimeLabel
	label.text = str(fight_time_left)
	
func get_winning_player():
	var p1 = $player1 as Player
	var p2 = $player2 as Player
	if p1.health > p2.health:
		return p1
	else:
		return p2

func show_win_menu():
	var menu: PauseMenu = $end_menu
	if menu:
		menu.visible = true
		var winner = get_winning_player()
		menu.update_label(winner.name + " wins!")
		get_tree().call_deferred("set_pause", true)

func _on_timer_timeout() -> void:
	if fight_time_left > 0:
		fight_time_left -= 1
		update_time_label()
	else:
		show_win_menu()
