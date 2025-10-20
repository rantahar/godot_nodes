class_name LevelLogic
extends NavigationRegion2D

signal structure_selected(node)

@onready var tile_map: TileMapLayer = $Map
@onready var rebake_timer: Timer = $RebakeTimer
var path_cache: Dictionary = {}
var rebake_requested = true

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
	new_unit.expansion = unit_data["init_expansion"]
	new_unit.set_movement_target(unit_data["target_expansion"])
	unit_data.ability._on_unit_created(new_unit)

func refresh():
	rebake_requested = true
	if rebake_timer.is_stopped():
		rebake_timer.start()

func rebake():
	bake_navigation_polygon()
	if rebake_requested:
		rebake_timer.start()
		rebake_requested = false

func remove_close_waypoints(path):
	if path.size() <= 1:
		return path
	const MIN_DISTANCE_THRESHOLD = 100.0
	var start_point = path[0]
	var first_far_index = path.size()-1
	for i in range(1, path.size()):
		if path[i].distance_to(start_point) >= MIN_DISTANCE_THRESHOLD:
			first_far_index = i
			break
	return path.slice(first_far_index)

func recalculate_all_paths():
	path_cache.clear()
	var expansions = get_tree().get_nodes_in_group("expansions")
	var nav_map = get_world_2d().navigation_map
	for exp_a in expansions:
		path_cache[exp_a] = {}
		for exp_b in expansions:
			if exp_a == exp_b:
				continue
			var start_point = NavigationServer2D.map_get_closest_point(nav_map, exp_a.global_position)
			var path = NavigationServer2D.map_get_path(nav_map, start_point, exp_a.global_position, true)
			path = remove_close_waypoints(path)
			path_cache[exp_a][exp_b] = path
	print("Path cache recalculated for %s expansions." % expansions.size())

func _on_structure_destroyed(structure):
	refresh()

func _on_structure_built(structure):
	refresh()
