class_name LevelLogic
extends Node2D

@onready var tile_map: TileMapLayer = $Map

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
