class_name Grid
extends Node2D

signal resources_updated()

@export var player_index: int = 0
var controller : Player = null
var structures: Array[Structure] = []

func _init():
	EventBus.resources_generated.connect(_on_resources_generated)

var resources: int = 200:
	set(value):
		resources = value
		emit_signal("resources_updated")

func _on_resources_generated(amount: int, target_grid: Grid):
	if target_grid == self:
		self.resources += amount

func can_afford(cost: int) -> bool:
	return resources >= cost

func spend_resources(cost: int):
	self.resources -= cost

func charge_maintenance(cost: int):
	if can_afford(cost):
		spend_resources(cost)
		return true
	else:
		return false

func _on_structure_destroyed(structure):
	structures.erase(structure)
