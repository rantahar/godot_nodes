class_name LevelLogic
extends NavigationRegion2D

signal structure_selected(node)

@onready var tile_map: TileMapLayer = $Map
var path_cache: Dictionary = {}

func _init():
	EventBus.unit_produced.connect(_on_unit_produced)

func _ready():
	await get_tree().process_frame
	self.bake_finished.connect(recalculate_all_paths)
	refresh()

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

func _on_unit_produced(unit_data: Dictionary):
	var new_unit = unit_data.scene.instantiate()
	add_child(new_unit)
	new_unit.grid = unit_data.grid
	new_unit.global_position = unit_data.position
	new_unit.target_structure = unit_data["init_structure"]
	new_unit.set_movement_target(unit_data["target_structure"])

func refresh():
	await get_tree().physics_frame # Wait any new obstacles to register
	bake_navigation_polygon()
	await get_tree().physics_frame
	bake_navigation_polygon()

func remove_close_waypoints(path):
	if path.size() <= 1:
		return path
	const MIN_DISTANCE_THRESHOLD = 256.0
	var start_point = path[0]
	var first_far_index = path.size()-1
	for i in range(1, path.size()):
		if path[i].distance_to(start_point) >= MIN_DISTANCE_THRESHOLD:
			first_far_index = i
			break
	return path.slice(first_far_index)

func recalculate_all_paths():
	path_cache.clear()
	var structures = get_tree().get_nodes_in_group("structures")
	var nav_map = get_world_2d().navigation_map
	for structure_a in structures:
		path_cache[structure_a] = {}
		for structure_b in structures:
			if structure_a == structure_b:
				continue
			var start_point = NavigationServer2D.map_get_closest_point(nav_map, structure_a.global_position)
			var path = NavigationServer2D.map_get_path(nav_map, start_point, structure_b.global_position, true)
			print(path.size())
			path = remove_close_waypoints(path)
			print(path.size())
			path_cache[structure_a][structure_b] = path
	print("Path cache recalculated for %s structures." % structures.size())

func _on_structure_destroyed(structure):
	refresh()

func _on_structure_built(structure):
	refresh()
