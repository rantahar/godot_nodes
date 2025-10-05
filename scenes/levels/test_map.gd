class_name LevelLogic
extends NavigationRegion2D

signal structure_selected(node)

@onready var tile_map: TileMapLayer = $Map
const ConnectionScene = preload("res://scenes/structures/connection.tscn")

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

func is_occupied(position: Vector2, shape) -> bool:
	var map_coords = tile_map.local_to_map(position)
	var tile_data = tile_map.get_cell_tile_data(map_coords)
	if not tile_data or not tile_data.get_custom_data("is_buildable"):
		return true
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = 1
	query.collide_with_areas = true
	var results = space_state.intersect_shape(query)
	
	if not space_state.intersect_shape(query).is_empty():
		return true
		
	return false

func get_all_crystals() -> Array:
	var crystal_nodes = []
	for node in get_children():
		if node is Crystal:
			crystal_nodes.append(node)
	return crystal_nodes

func get_available_crystal_at(mouse_pos):
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

func get_connecting_nodes(position, distance, all = false):
	var connections = []
	var objects = find_objects_at(position, distance)
	return connections

func find_connection_for_structure(position, max_distance, factions, all):
	var connections = []
	var nearby_nodes = get_connecting_nodes(position, max_distance, all)
	for node in nearby_nodes:
		if node.faction in factions:
			connections.append(node)
	return connections

func is_structure_location_occupied(structure_data, position):
	var ghost_instance = structure_data.scene.instantiate()
	var collision_shape_node = ghost_instance.find_child("CollisionShape2D")
	var shape_resource = collision_shape_node.shape
	var occupied = is_occupied(position, shape_resource)
	ghost_instance.queue_free()
	if is_occupied(position, shape_resource):
		return true
	return false

func _on_structure_destroyed(structure):
	bake_navigation_polygon()

func _on_build_approved(structure_data, expansion, faction):
	var new_node = structure_data.scene.instantiate()
	new_node.faction = faction
	expansion.add_child(new_node)

	new_node.structure_destroyed.connect(faction._on_structure_destroyed)
	new_node.structure_destroyed.connect(_on_structure_destroyed)
	if structure_data.generates_resource:
		new_node.resources_generated.connect(faction._on_node_generated_resources)
