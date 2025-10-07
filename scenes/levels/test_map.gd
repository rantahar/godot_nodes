class_name LevelLogic
extends NavigationRegion2D

signal structure_selected(node)

@onready var tile_map: TileMapLayer = $Map
const ConnectionScene = preload("res://scenes/structures/connection.tscn")

func _init():
	EventBus.unit_produced.connect(_on_unit_produced)

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
	new_unit.set_movement_target(unit_data.rally_point.global_position)

func _on_structure_destroyed(structure):
	bake_navigation_polygon()
