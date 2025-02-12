extends Node

func show_number(n: int, position: Vector2):
	var label = Label.new()
	label.global_position = position
	label.text = str(n)
	label.z_index = 5 # arbitrary index to be shown on top of other sprites
	label.label_settings = LabelSettings.new()
	
	var color = '#FFF'
	if n == 0:
		color = '#FFF8'
		
	label.label_settings.font_color = color
	label.label_settings.font_size = 18
	label.label_settings.outline_color = '#000'
	label.label_settings.outline_size = 1
	
	call_deferred("add_child", label)
	
	# we have to wait until this signal is emitted to have a "size" propoerty in our label
	await label.resized
	
	# set pivot offset to horizontal center of the label
	label.pivot_offset = Vector2(label.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# animating up
	tween.tween_property(
		label,
		"position:y",
		label.position.y - 24,
		0.25
	).set_ease(Tween.EASE_OUT)
	
	# animating down
	tween.tween_property(
		label,
		"position:y",
		label.position.y,
		0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	
	# animating disapearing
	tween.tween_property(
		label,
		"scale",
		Vector2.ZERO,
		0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	label.queue_free()
