class_name Ability
extends Node2D

var parent: Node2D
var is_active = true
var is_passive = true
var has_button = false

func _ready():
	parent = get_parent()
	disable()

func enable():
	is_active = true
	set_process(true)
	for child in get_children():
		if child is Timer:
			if child.is_stopped():
				child.start()

func disable():
	is_active = false
	set_process(false)
	for child in get_children():
		if child is Timer:
			child.stop()

func toggle():
	# Some abilites can be toggled using the toggle UI button
	pass

func is_executing() -> bool:
	return false

func can_execute() -> bool:
	return false

func charge_ability_cost(cost):
	return parent.charge_ability_cost(cost)
