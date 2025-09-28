class_name Player
extends Node

signal resources_updated()
signal build_approved(structure_data, position, factions, connections, free)

const MAX_BUILD_DISTANCE = 128

var factions: Array[Faction] = []

var buildable_structures = {
	"network_node": {
		"name": "network_node",
		"scene": preload("res://node.tscn"),
		"cost": 15,
		"generates_resource": false
	},
	"cannon": {
		"name": "cannon",
		"scene": preload("res://cannon.tscn"),
		"cost": 50,
		"generates_resource": false
	},
	"mine": {
		"name": "mine",
		"scene": preload("res://mine.tscn"),
		"cost": 50,
		"generates_resource": true
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


func build_structure(mouse_pos, build_mode, free = false) -> void:
	if not build_mode:
		return

	var structure_data = buildable_structures[build_mode]
	if not structure_data:
		return
	
	emit_signal("build_approved", structure_data, mouse_pos, factions, MAX_BUILD_DISTANCE, free)
