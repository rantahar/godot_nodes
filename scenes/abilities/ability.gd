class_name Ability
extends Node2D

var parent: Node2D
var is_active = true
var is_passive = true
var has_button = false
var ability_data: Dictionary

@export var ability_name: String = ""

func _ready():
	print(ability_name)
	parent = get_parent()
	ability_data = GameData.abilities.get(ability_name, {})

func check_prerequisites() -> bool:
	print(ability_data, " ", ability_data.has("prerequisites"))
	if not ability_data or not ability_data.has("prerequisites"):
		return true
	
	var prereqs = ability_data.get("prerequisites", {})
	if prereqs.has("upgrade"):
		var player = parent.grid.controller if parent.grid else null
		if not player or not player.has_upgrade(prereqs["upgrade"]):
			return false
	
	if prereqs.has("structure"):
		var grid = parent.grid if parent.grid else null
		if not grid or not grid.has_structure_type(prereqs["structure"]):
			return false
	
	return true

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
