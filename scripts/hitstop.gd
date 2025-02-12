extends Node

func freeze_short():
	freeze_time(0.15)
	
func freeze_long():
	freeze_time(0.5)

func freeze_time(time_ms: float):
	Engine.time_scale = 0
	await get_tree().create_timer(time_ms, true, false, true).timeout
	Engine.time_scale = 1

func slow_motion_short():
	slow_motion(0.15)

func slow_motion_long():
	slow_motion(0.5)

func slow_motion(time_ms: float):
	Engine.time_scale = 0.5
	await get_tree().create_timer(time_ms, true, false, true).timeout
	Engine.time_scale = 1
