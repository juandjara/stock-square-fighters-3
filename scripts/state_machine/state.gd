extends Node
class_name State

signal transitioned

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass
	
func physics_update(delta: float):
	pass

func transition(state_name: String):
	transitioned.emit(self, state_name)
