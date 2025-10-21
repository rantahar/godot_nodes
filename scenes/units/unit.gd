class_name Unit
extends CharacterBody2D

@export var unit_type: String = ""
var stats
var max_health: int = 5
var health: int = 5
var size = 4

var grid: Grid = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selectionIndicator = $SelectionIndicator
@onready var separation_area = $SeparationArea
@onready var AI_timer = $AITimer

enum State { TRAVELING, ENGAGING }
var current_state = State.ENGAGING
var expansion: ExpansionNode
var current_target: Node2D = null
var engagement_range: float = 16
var engagement_tolerance: float = 8
var ARRIVAL_RANGE: float = 64
var DETECTION_RANGE: float = 256

var target_priorities = ["units", "main_building", "mine"]

# traveling:
var target_waypoint
var WAYPOINT_TARGET_RADIUS = 32
var cached_path
var cached_path_index = 0
# engaging:
var SEPARATION_WEIGHT = 10
var FRICTION = 20
var turn_speed = 5
var desired_velocity = Vector2.ZERO

var resource = 5

func _ready():
	var gamedata = GameData
	stats = grid.controller.get_unit_stats(unit_type)
	max_health = stats["max_health"]
	health = max_health
	
	engagement_range = stats["range"]
	
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	var shape_size = $CollisionShape2D.shape.get_rect().size
	$HealthBar.position.y = -shape_size.y-8
	$HealthBar.size.x = shape_size.x
	nav_agent.target_position = global_position
	
	AI_timer.timeout.connect(_update_ai)
	AI_timer.start(randf_range(0.0, AI_timer.wait_time))

func _process(delta):
	enforce_ability_priority(delta)

func enforce_ability_priority(delta):
	var abilities = get_abilities_in_order()
	
	var an_ability_is_blocking = false
	for ability in abilities:
		if not ability.is_passive:
			continue
		if an_ability_is_blocking:
			ability.disable()
		else:
			ability.enable()
			if ability.is_executing():
				an_ability_is_blocking = true

func get_abilities_in_order() -> Array[Ability]:
	var result: Array[Ability] = []
	for child in get_children():
		if child is Ability:
			result.append(child)
	return result

func get_cached_path(target):
	var level = get_parent()
	if not expansion in level.path_cache:
		cached_path = []
		return
	var paths = level.path_cache[expansion]
	if not target in paths:
		cached_path = []
		return
	cached_path = paths[target]
	cached_path_index = 0

func set_movement_target(target):
	if target is Structure:
		target = target.expansion
	expansion.unregister_unit(self)
	target.register_unit(self)
	if not target or not target is ExpansionNode or target == expansion:
		return
	get_cached_path(target)
	expansion = target
	nav_agent.avoidance_enabled = true
	current_state = State.TRAVELING
	set_waypoint()
	nav_agent.target_position = target_waypoint

func set_waypoint():
	if cached_path_index >= cached_path.size():
		if is_instance_valid(expansion):
			target_waypoint = expansion.global_position
	else:
		target_waypoint = cached_path[cached_path_index]

func check_waypoint():
	if global_position.distance_to(target_waypoint) < WAYPOINT_TARGET_RADIUS:
		cached_path_index += 1
		set_waypoint()
		nav_agent.target_position = target_waypoint

func find_target_in_expansion():
	if not is_instance_valid(expansion):
		return null
	
	var level = get_parent()
	for unit in expansion.units:
		if unit is Unit and unit.grid != grid:
			var dist = global_position.distance_to(unit.global_position)
			if dist < DETECTION_RANGE:
				return unit
	
	for priority_type in target_priorities:
		for structure in expansion.structures:
			if structure.grid == grid:
				continue
			
			if structure.building_type == priority_type:
				return structure
	
	for structure in expansion.structures:
			if structure.grid == grid:
				continue
			return structure

func right_click_command(location):
	set_movement_target(location)

func charge_ability_cost(cost) -> bool:
	if cost <= resource:
		resource -= cost
		return true
	return false

func get_separation_force() -> Vector2:
	var push_vector = Vector2.ZERO
	var neighbors = separation_area.get_overlapping_areas() 
	if neighbors.is_empty():
		return Vector2.ZERO
		
	for area in neighbors:
		var neighbor_unit = area.get_parent()
		if neighbor_unit != self:
			var diff = global_position - neighbor_unit.global_position
			var distance = diff.length()
			var push_force = diff / (distance)
			push_vector += push_force
	return push_vector

func _travel_process(delta):
	check_waypoint()
	var target_position
	if is_instance_valid(expansion):
		target_position = expansion.global_position
	else:
		target_position = global_position
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < ARRIVAL_RANGE:
		current_state = State.ENGAGING
		nav_agent.target_position = global_position
		nav_agent.avoidance_enabled = false
		return
	var target_point = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_point)
	var new_velocity = direction * stats.speed
	nav_agent.set_velocity(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	if current_state == State.TRAVELING:
		velocity = safe_velocity

func _engage_process(delta):
	if not is_instance_valid(current_target):
		current_target = find_target_in_expansion()
	
	desired_velocity = Vector2.ZERO
	
	if not is_instance_valid(current_target):
		var target_position = global_position
		if is_instance_valid(expansion):
			target_position = expansion.global_position
		var to_target = target_position - global_position
		var distance = to_target.length() - expansion.size
		if distance > engagement_range:
			desired_velocity = to_target.normalized() * stats.speed
		var separation_force = get_separation_force() * SEPARATION_WEIGHT 
		desired_velocity += separation_force * stats.speed
	
	else:
		var to_target = current_target.global_position - global_position
		var distance = to_target.length() - current_target.size
		if distance > engagement_range:
			desired_velocity = to_target.normalized() * stats.speed
		elif distance < (engagement_range - engagement_tolerance):
			desired_velocity = -to_target.normalized() * stats.speed * 0.5
		var separation_force = get_separation_force() * SEPARATION_WEIGHT
		desired_velocity += separation_force * stats.speed
	
	desired_velocity = desired_velocity.limit_length(stats.speed)
	
func _physics_process(delta):
	if current_state == State.ENGAGING:
		velocity = velocity.lerp(desired_velocity, turn_speed * delta)
		if desired_velocity.length() < 1:
			velocity = velocity.lerp(Vector2.ZERO, turn_speed * delta)
			if velocity.length() < 2:
				velocity = Vector2.ZERO
	move_and_slide()

func _update_ai():
	match current_state:
		State.ENGAGING:
			_engage_process(AI_timer.wait_time)
		State.TRAVELING:
			_travel_process(AI_timer.wait_time)

func take_damage(amount: int):
	health -= amount
	$HealthBar.value = health
	if health <= 0:
		queue_free()

func _exit_tree():
	if is_instance_valid(expansion):
		expansion.unregister_unit(self)
