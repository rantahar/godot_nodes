class_name Faction
extends Node

const NODE_BUILD_COST = 15

signal resources_updated()

@export var player_index: int = 0
var controller : Player = null

var resources: int = 50:
	set(value):
		resources = value
		print("Faction resources updated: ", value, " ", self)
		emit_signal("resources_updated")

func _on_node_generated_resources(amount: int):
	self.resources += amount

func can_afford(cost: int) -> bool:
	return resources >= cost

func spend_resources(cost: int):
	self.resources -= cost
