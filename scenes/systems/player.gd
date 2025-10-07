class_name Player
extends Node

signal resources_updated()
signal build_approved(structure_data, position, grids, connections)
signal player_won(player, time_elapsed)

const MAX_BUILD_DISTANCE = 128
const WIN_CONDITION_RESOURCES = 100000
var has_won: bool = false
@export var color: Color = Color.GREEN

var main_buildings: Array[MainBuilding] = []
var grids: Array[Grid] = []
var level: LevelLogic = null

var buildable_structures = {
	"main_building": {
		"name": "network_node",
		"scene": preload("res://scenes/structures/main_building.tscn"),
		"cost": 300,
		"generates_resource": false,
		"location": "main"
	},
	"mine": {
		"name": "mine",
		"scene": preload("res://scenes/structures/mine.tscn"),
		"cost": 50,
		"generates_resource": true,
		"location": "crystal"
	},
	"cannon": {
		"name": "cannon",
		"scene": preload("res://scenes/structures/cannon.tscn"),
		"cost": 100,
		"generates_resource": false,
		"location": "building_slot"
	},
	"factory": {
		"name": "factory",
		"scene": preload("res://scenes/structures/factory.tscn"),
		"cost": 150,
		"generates_resource": false,
		"location": "building_slot"
	}
}

var node_container : Node = null

var resources: int:
	get:
		var total = 0
		if grids: # Check if the array is populated
			for grid in grids:
				total += grid.resources
		return total

func _on_resources_updated():
	emit_signal("resources_updated", resources)
	if not has_won and resources >= WIN_CONDITION_RESOURCES:
		has_won = true
		var time_msec = Time.get_ticks_msec()
		emit_signal("player_won", self, time_msec)

func find_build_grid_for(expansion: ExpansionNode, structure_data):
	if not expansion.is_free:
		if expansion.grid in grids:
			return expansion.grid
		else:
			return null
	elif structure_data.location == "main":
		for connection in expansion.connected_nodes:
			if not connection.is_free and connection.grid in grids:
				return connection.grid

func can_claim_expansion(expansion: ExpansionNode) -> bool:
	if not expansion.is_free:
		return false

	for connection in expansion.connected_nodes:
		if not connection.is_free and connection.grid in grids:
			return true
	return false

func build_structure(expansion, build_mode, free = false) -> void:
	if not build_mode:
		return
	
	var structure_data = buildable_structures[build_mode]
	var grid = find_build_grid_for(expansion, structure_data)
	
	if not expansion.can_build(structure_data):
		print("Build failed: No valid slots available.")
		return
	
	if not free:
		if not is_instance_valid(grid):
			print("Build failed: No valid friendly grid.")
		if not grid.can_afford(structure_data.cost):
			print("Build failed: Cannot afford.")
			return
		else:
			grid.spend_resources(structure_data.cost)
	else:
		grid = grids[0]
	
	expansion.build(structure_data, grid)
