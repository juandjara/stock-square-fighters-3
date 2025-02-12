class_name HealthBar
extends ProgressBar

@onready var timer = $timer
@onready var damage_bar: ProgressBar = $damage_bar
@onready var energy_bar: ProgressBar = $energy_bar

func _ready() -> void:
	damage_bar.fill_mode = fill_mode
	energy_bar.fill_mode = fill_mode
	if (fill_mode == FillMode.FILL_END_TO_BEGIN):
		energy_bar.position.x = 208
	else:
		energy_bar.position.x = 0

func update(new_value: float):
	if value > 0:
		value = new_value
		timer.start()
		await timer.timeout
		damage_bar.value = new_value

func update_energy(new_value: float):
	energy_bar.value = new_value
