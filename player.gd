class_name Player
extends Node

signal resources_updated()

const MAX_BUILD_DISTANCE = 128

var factions: Array[Faction] = []

var buildable_structures = {
	"network_node": {
		"scene": preload("res://node.tscn"),
		"cost": 15
	},
	"cannon": {
		"scene": preload("res://cannon.tscn"),
		"cost": 50
	},
	"mine": {
		"scene": preload("res://mine.tscn"),
		"cost": 50
	}
}

const ConnectionScene = preload("res://connection.tscn")
var node_container : Node = null
var inputController : Node2D = null

var resources: int:
	get:
		var total = 0
		if factions: # Check if the array is populated
			for faction in factions:
				total += faction.resources
		return total

func _on_resources_updated():
	emit_signal("resources_updated", resources)

func create_structure(position, faction: Faction, scene):
	var new_node = scene.instantiate()
	new_node.global_position = position
	new_node.faction = faction
	node_container.add_child(new_node)
	new_node.structure_selected.connect(inputController._on_node_selected)
	return new_node

func create_connection(node_a: Structure, node_b: Structure):
	var new_connection = ConnectionScene.instantiate()
	node_container.add_child(new_connection)
	new_connection.node_a = node_a
	new_connection.node_b = node_b
	node_a.add_connection(new_connection)
	node_b.add_connection(new_connection)
	new_connection.update_line_visuals()

func build_structure(mouse_pos, build_mode, free = false) -> void:
	if not build_mode:
		return

	var faction = factions[0]
	var structure_data = buildable_structures[build_mode]
	if not structure_data:
		return
	
	var objects = node_container.find_objects_at(mouse_pos, MAX_BUILD_DISTANCE)
	var builder_found = false
	var nearby_network_nodes = []
	for node in objects:
		if build_mode == "network_node" or node is NetworkNode:
			if node is Structure and node.faction in factions:
				nearby_network_nodes.append(node)
				if node.is_built:
					faction = node.faction
	
	if nearby_network_nodes.is_empty():
		if not free:
			return
	
	if build_mode == "mine":
		var crystal = node_container.find_available_crystal_at(mouse_pos)
		if crystal and faction.can_afford(structure_data.cost):
			faction.spend_resources(structure_data.cost)
			var new_mine = create_structure(mouse_pos, faction, structure_data.scene)
			new_mine.resources_generated.connect(faction._on_node_generated_resources)
			crystal.has_mine_on_it = true
			for neighbor in nearby_network_nodes:
				create_connection(new_mine, neighbor)
		return
	
	var ghost_instance = structure_data.scene.instantiate()
	var collision_shape_node = ghost_instance.find_child("CollisionShape2D")
	var shape_resource = collision_shape_node.shape
	if not node_container.is_build_location_valid(mouse_pos, shape_resource):
		ghost_instance.queue_free()
		return
	
	if not free:
		if faction.can_afford(structure_data.cost):
			faction.spend_resources(structure_data.cost)
		else:
			print("Not enough resources!")
			return
	var structure = create_structure(mouse_pos, faction, structure_data.scene)
	for neighbor in nearby_network_nodes:
		create_connection(structure, neighbor)
	
	ghost_instance.queue_free()
