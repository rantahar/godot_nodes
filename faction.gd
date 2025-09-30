class_name Faction
extends Node2D

signal resources_updated()

@export var player_index: int = 0
var controller : Player = null
var structures: Array[Structure] = []


var resources: int = 50:
	set(value):
		resources = value
		emit_signal("resources_updated")

func _on_node_generated_resources(amount: int):
	self.resources += amount

func can_afford(cost: int) -> bool:
	print(resources, " afford ", cost)
	return resources >= cost

func spend_resources(cost: int):
	self.resources -= cost

func _on_structure_destroyed(structure):
	structures.erase(structure)
