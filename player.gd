class_name Player
extends Node

signal resources_updated()
signal build_approved(structure_data, position, factions, connections)
signal player_won(player, time_elapsed)

const MAX_BUILD_DISTANCE = 128
const WIN_CONDITION_RESOURCES = 1000
var has_won: bool = false
@export var color: Color = Color.GREEN

var factions: Array[Faction] = []
var level: LevelLogic = null

var buildable_structures = {
	"network_node": {
		"name": "network_node",
		"scene": preload("res://node.tscn"),
		"cost": 15,
		"generates_resource": false
	},
	"mine": {
		"name": "mine",
		"scene": preload("res://mine.tscn"),
		"cost": 50,
		"generates_resource": true
	},
	"cannon": {
		"name": "cannon",
		"scene": preload("res://cannon.tscn"),
		"cost": 100,
		"generates_resource": false
	},
	"factory": {
		"name": "factory",
		"scene": preload("res://factory.tscn"),
		"cost": 150,
		"generates_resource": false
	}
}

var node_container : Node = null

var resources: int:
	get:
		var total = 0
		if factions: # Check if the array is populated
			for faction in factions:
				total += faction.resources
		return total

func _on_resources_updated():
	emit_signal("resources_updated", resources)
	if not has_won and resources >= WIN_CONDITION_RESOURCES:
		has_won = true
		var time_msec = Time.get_ticks_msec()
		emit_signal("player_won", self, time_msec)


func build_location_valid(structure_data, position, factions, max_distance):
	if structure_data.name == "mine":
		var crystal = level.get_available_crystal_at(position)
		if not crystal:
			return false
	else:
		if level.is_structure_location_occupied(structure_data, position):
			return false
	
	# Check that it connects to a finished network node
	var connections = level.find_connection_for_structure(position, max_distance, factions, false)
	var builder_found = false
	for node in connections:
		if node.is_built:
			builder_found = true
	if not builder_found:
		return false
	
	return true


func build_structure(mouse_pos, build_mode, free = false) -> void:
	if not build_mode:
		return
	
	var faction : Faction = null
	var connections = []
	var structure_data = buildable_structures[build_mode]
	
	if not free:
		if not build_location_valid(structure_data, mouse_pos, factions, MAX_BUILD_DISTANCE):
			return
		
		var connect_all = structure_data.name == "network_node"
		connections = level.find_connection_for_structure(mouse_pos, MAX_BUILD_DISTANCE, factions, connect_all)
		faction = connections[0].faction
		if not faction.can_afford(structure_data.cost):
			print("Not enough resources!")
		else:
			faction.spend_resources(structure_data.cost)
	else:
		faction = factions[0]
	
	if structure_data.name == "mine":
		var crystal = level.get_available_crystal_at(mouse_pos)
		if crystal:
			mouse_pos = crystal.global_position
		else:
			return

	emit_signal("build_approved", structure_data, mouse_pos, faction, connections)
