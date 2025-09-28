class_name LevelLogic
extends Node2D

@onready var tile_map: TileMapLayer = $Map

const ConnectionScene = preload("res://connection.tscn")

func find_objects_at(position: Vector2, radius: float = 1, collision_mask: int = 1):
	var space_state = get_world_2d().direct_space_state
	var found_objects = []
	
	var shape = CircleShape2D.new()
	shape.radius = radius
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		found_objects.append(result.collider.get_parent())
		
	return found_objects

func is_build_location_valid(position: Vector2, shape) -> bool:
	var map_coords = tile_map.local_to_map(position)
	var tile_data = tile_map.get_cell_tile_data(map_coords)
	if not tile_data or not tile_data.get_custom_data("is_buildable"):
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = 1
	query.collide_with_areas = true
	var results = space_state.intersect_shape(query)
	
	if not space_state.intersect_shape(query).is_empty():
		return false
		
	return true

func find_available_crystal_at(mouse_pos):
	var objects = find_objects_at(mouse_pos)
	for node in objects:
		if node is Crystal and not node.has_mine_on_it:
			return node
	return null

func create_connection(node_a: Structure, node_b: Structure):
	var new_connection = ConnectionScene.instantiate()
	add_child(new_connection)
	new_connection.node_a = node_a
	new_connection.node_b = node_b
	node_a.add_connection(new_connection)
	node_b.add_connection(new_connection)
	new_connection.update_line_visuals()

func _on_build_approved(structure_data, position, factions, max_distance, free):
	# Check nearby nodes for connections and at least one live builder node
	var faction = factions[0]
	var objects = find_objects_at(position, max_distance)
	var builder_found = false
	var nearby_network_nodes = []
	for node in objects:
		if structure_data.name == "network_node" or node is NetworkNode:
			if node is Structure and node.faction in factions:
				nearby_network_nodes.append(node)
				faction = node.faction
				if node.is_built:
					builder_found = true
	
	if not builder_found:
		if not free:
			return
	
	if not free:
		if not faction.can_afford(structure_data.cost):
			print("Not enough resources!")
			return
	
	if structure_data.name == "mine":
		var crystal = find_available_crystal_at(position)
		if crystal:
			crystal.has_mine_on_it = true
			position = crystal.global_position
		else:
			return
	
	else:
		var ghost_instance = structure_data.scene.instantiate()
		var collision_shape_node = ghost_instance.find_child("CollisionShape2D")
		var shape_resource = collision_shape_node.shape
		if not is_build_location_valid(position, shape_resource):
			ghost_instance.queue_free()
			return
		ghost_instance.queue_free()
	
	if not free:
		faction.spend_resources(structure_data.cost)
	var new_node = structure_data.scene.instantiate()
	new_node.global_position = position
	new_node.faction = faction
	add_child(new_node)
	for neighbor in nearby_network_nodes:
		create_connection(new_node, neighbor)
	
	if structure_data.generates_resource:
		new_node.resources_generated.connect(faction._on_node_generated_resources)
	
	
	
