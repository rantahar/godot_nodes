class_name Ability
extends Node2D

var parent: Node2D
var is_active = true
@export var has_button = false
@export var ability_cost: Dictionary = {}

func _ready():
	parent = get_parent()
	enable()

func enable():
	is_active = true
	set_process(true)

func disable():
	is_active = false
	set_process(false)

func toggle():
	# Some abilites can be toggled using the toggle active UI button
	pass

func charge_ability_cost(cost):
	return parent.charge_ability_cost(cost)
