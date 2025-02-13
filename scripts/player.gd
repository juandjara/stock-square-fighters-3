class_name Player
extends CharacterBody2D

const TARGET_SPRITE_SIZE = 153 # px
const MAX_HEALTH = 200

const SPEED_STEP = 60.0
const SPEED = 300.0
const JUMP_SPEED = -750.0

const ENERGY_STEP = 0.15
const MAX_ENERGY = 1.5 # seconds needed to fire a energy ball

const PARRY_STEP = 0.05
const MIN_PARRY_TIME = 0.1 # seconds

const BASE_STAT = 3
const BASE_DAMAGE = 5

@export var is_controlled: bool = true
@export_enum("left", "right") var initial_place: String = "left"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Node2D = $sprite
@onready var sprite_inner: Node2D = $sprite/Sprite2D

var bullet_scene = preload("res://scenes/bullet.tscn")
var initial_sprite_scale: float = 1
var pushback_force: Vector2
var health = 200

var energy_loaded: float = 0

var defense_time: float = 0
var defense_start_key: String

var state = "idle"
var persistent_states = ["energy_load", "defense"]

var character_data: CharacterData

func _ready() -> void:
	initial_sprite_scale = sprite.scale.x
	if initial_place == 'right':
		sprite.scale.x *= -1


# called from world.gd when instantiating the players
func init_data(data: CharacterData):
	if not data:
		return
	
	character_data = data
	
	sprite_inner.texture = data.sprite
	var scale_x = float(TARGET_SPRITE_SIZE) / float(sprite_inner.texture.get_width())
	var scale_y = float(TARGET_SPRITE_SIZE) / float(sprite_inner.texture.get_height())
	sprite_inner.scale.x = scale_x
	sprite_inner.scale.y = scale_y
	
	get_health_bar().call_deferred("set_name_label", character_data.name)


func get_jump_speed():
	var stat = character_data.energy - BASE_STAT
	return JUMP_SPEED + (stat * -SPEED_STEP)


func get_move_speed():
	var stat = character_data.energy - BASE_STAT
	return SPEED + (stat * SPEED_STEP)


func get_parry_time():
	var stat = character_data.energy - BASE_STAT
	return MIN_PARRY_TIME + (stat * PARRY_STEP)


func get_max_energy():
	var stat = character_data.energy - BASE_STAT
	return MAX_ENERGY - (stat * ENERGY_STEP)


func get_energy_damage():
	var stat = character_data.energy - BASE_STAT
	return BASE_DAMAGE + stat


func get_damage():
	var stat = character_data.attack - BASE_STAT
	return BASE_DAMAGE + stat


func get_defense():
	var stat = character_data.defense - BASE_STAT
	return BASE_DAMAGE + stat


func get_keys() -> Dictionary:
	if initial_place == 'left':
		return {
			"atk1": "p1_atk1",
			"atk2": "p1_atk2",
			"up": "p1_up",
			"down": "p1_down",
			"right": "p1_right",
			"left": "p1_left"
		}
	if initial_place == 'right':
		return {
			"atk1": "p2_atk1",
			"atk2": "p2_atk2",
			"up": "p2_up",
			"down": "p2_down",
			"right": "p2_right",
			"left": "p2_left"
		}
	return {}


func get_defense_key():
	var key = "left"
	var other = get_other_player()
	if other:
		var diff = global_position.x - other.global_position.x
		if diff > 0:
			key = "right"
			
	return get_keys()[key]


func _physics_process(delta: float) -> void:
	if is_controlled:
		if Input.is_action_just_pressed(get_keys()["atk1"]):
			transition("attack1")
		if Input.is_action_just_pressed(get_keys()["atk2"]):
			transition("attack2")
		if Input.is_action_just_pressed(get_keys()["down"]) and is_on_floor():
			transition("load_energy")
		if Input.is_action_just_pressed(get_defense_key()) and is_on_floor():
			transition("defense")
	
	if state == 'idle' or state == 'defense':
		process_movement(delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, delta * 10)
	
	if state == 'take_damage':
		process_pushback(delta)
	
	if state == 'load_energy':
		process_energy_load(delta)
		
	if state == 'defense':
		process_defense(delta)
	
	move_and_slide()
	
	face_other_player()


# this is a bad approximation to a state machine, but it works for now
func transition(new_state: String):
	# if prev state was "load_energy", reset energy levels
	if (state == 'load_energy'):
		update_energy(0)
	
	# if prev state was "defense", hide the shield sprite and reset defense time
	if state == "defense":
		defense_time = 0
		$sprite/shield.visible = false
	
	if animation_player.is_playing():
		# TODO: detect if animation is looping instead of checking by name
		if animation_player.current_animation == 'load_energy':
			animation_player.stop()
		else:
			# wait to finish current animation before transitioning to new state
			await animation_player.animation_finished
	
	if state != new_state:
		state = new_state
		if animation_player.has_animation(state):
			animation_player.play(state)
		else:
			animation_player.play("RESET")

	if new_state == 'defense':
		defense_time = 0
		defense_start_key = get_defense_key()
		$sprite/shield.visible = true

	# only receive input for attack, movement and more when state is "idle"
	if new_state == "idle" or new_state == 'defense':
		is_controlled = true
	else:
		is_controlled = false
		
		# transition to "idle" after animation finished if state is not persistent
		if not persistent_states.has(state):
			await animation_player.animation_finished
			transition("idle")


func process_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if is_controlled and Input.is_action_just_pressed(get_keys()["up"]) and is_on_floor():
		velocity.y = get_jump_speed() # JUMP_SPEED

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(get_keys()["left"], get_keys()["right"])
	if is_controlled and direction:
		velocity.x = direction * get_move_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, get_move_speed())


func process_pushback(delta: float):
	if pushback_force.length() != 0:
		velocity += pushback_force
		pushback_force = lerp(pushback_force, Vector2.ZERO, delta * 20)


func process_energy_load(delta: float):	
	if Input.is_action_pressed(get_keys()["down"]):
		update_energy(energy_loaded + delta)
	
	if Input.is_action_just_released(get_keys()["down"]):
		if (energy_loaded >= get_max_energy()):
			fire_energy()
		
		transition("idle")


func process_defense(delta: float):
	if Input.is_action_pressed(defense_start_key):
		defense_time += delta
	
	var curr_defense_key = get_defense_key()
	if curr_defense_key != defense_start_key or Input.is_action_just_released(defense_start_key):
		transition("idlw")


# called every frame in _process_phyisics
func face_other_player():
	var other = get_other_player()
	if not other:
		return
	
	if get_other_player().position.x < position.x:
		sprite.scale.x = initial_sprite_scale * -1
	else:
		sprite.scale.x = initial_sprite_scale


# stores energy and updates UI
func update_energy(value: float):
	energy_loaded = value
	var percent = max(0, energy_loaded * 100) / get_max_energy()
	get_health_bar().update_energy(percent)


# called in process_energy before transitioning out if enough energy was accumulated
func fire_energy():
	var bullet = bullet_scene.instantiate() as Bullet
	var diff = get_other_player().global_position.x - global_position.x
	bullet.direction = Vector2(sign(diff), 0)
	bullet.global_position = %bullet_spawn.global_position
	bullet.color = character_data.energy_color
	bullet.damage = get_energy_damage()
	$/root/world.add_child(bullet)


func get_other_player() -> Player:
	if initial_place == 'right':
		return $/root/world/player1
	else:
		return $/root/world/player2


func get_health_bar() -> HealthBar:
	if initial_place == 'right':
		return $/root/world/GUI/HP_Right
	else:
		return $/root/world/GUI/HP_Left


# the hurtbox script calls this methods when a hitbox collides with it
func take_hit(hitbox: HitBox):
	take_damage(hitbox.get_damage())
	
	var direction = (global_position - hitbox.global_position).normalized()
	add_pushback_force(direction)
	
	ExplosionSpawner.spawn((global_position + hitbox.global_position) / 2)
	
	if hitbox is Bullet:
		hitbox.queue_free()


func take_damage(amount: int):
	var was_defending = state == "defense"
	transition("take_damage")
	
	await Hitstop.freeze_short() # if we don't append "await" here, the movement of thing freezes but the scripts do not

	var rand_amount = roundi(randf_range(amount * 0.9, amount * 1.1))
	if was_defending:
		var def = get_defense()	
		rand_amount = max(0, rand_amount - def)
	
	DamageNumbers.show_number(rand_amount, $DamageNumberOrigin.global_position)
	
	health -= rand_amount
	var hp_percent = max(0, health * 100) / MAX_HEALTH
	get_health_bar().update(hp_percent)
	
	if health <= 0:
		$/root/world.show_win_menu()


# the hurtbox script calls this methods when a hitbox collides with it
func add_pushback_force(direction: Vector2):
	pushback_force = direction * 500


func can_parry():
	return state == 'defense' and defense_time < MIN_PARRY_TIME
