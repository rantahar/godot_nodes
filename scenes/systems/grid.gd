class_name Grid
extends Node2D

signal resources_updated()

@export var player_index: int = 0
var controller : Player = null
var expansions: Array[ExpansionNode] = []
var structures: Array[Structure] = []

func _init():
	EventBus.resources_generated.connect(_on_resources_generated)

var resources: Dictionary = {
	"crystal": 200,
	"red_crystal": 0,
	"blue_crystal": 0,
	"green_crystal": 0
}

func add_resources(type: String, amount: int):
	if resources.has(type):
		resources[type] += amount
	emit_signal("resources_updated")

func can_afford(cost: Dictionary) -> bool:
	for resource_type in cost:
		var required_amount = cost[resource_type]
		if resources.get(resource_type, 0) < required_amount:
			return false
	return true

func _on_resources_generated(resources: Dictionary, target_grid: Grid):
	if target_grid == self:
		for key in resources:
			add_resources(key, resources[key])

func spend_resources(cost: Dictionary):
	for resource_type in cost:
		var amount_to_spend = cost[resource_type]
		if resources.has(resource_type):
			resources[resource_type] -= amount_to_spend
	emit_signal("resources_updated")

func charge_maintenance(cost: Dictionary):
	if can_afford(cost):
		spend_resources(cost)
		return true
	else:
		return false

func _on_structure_destroyed(structure):
	structures.erase(structure)
