class_name Unit
extends CharacterBody2D

@export var unit_type: String = ""
var stats
var max_health: int = 5
var health: int = 5

var grid: Grid = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selectionIndicator = $SelectionIndicator
@onready var separation_area = $SeparationArea
@onready var AI_timer = $AITimer

enum State { SWARMING, TRAVELING }
var target_structure: Structure
var target_waypoint
var WAYPOINT_TARGET_RADIUS = 32
var cached_path
var cached_path_index = 0
var current_state = State.SWARMING
var ARRIVAL_RADIUS = 48.0
var SEPARATION_WEIGHT = 10
var GRAVITY_WEIGHT = 5
var DRAG_FACTOR = 20
var STOP_THRESHOLD_SPEED = 1
var turn_speed = 2

var resource = 5

func _ready():
	var gamedata = GameData
	stats = gamedata.buildable_units[unit_type]
	max_health = stats["max_health"]
	health = max_health
	
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
	var target_exp
	if target is Structure:
		target_exp = target.expansion
	elif target is ExpansionNode:
		target_exp = target
	else:
		return
	if not target_exp in level.path_cache:
		cached_path = []
		return
	var paths = level.path_cache[target_structure.expansion]
	if not target in paths:
		cached_path = []
		return
	cached_path = paths[target.expansion]
	cached_path_index = 0

func set_movement_target(target: Structure):
	if not target or target == target_structure:
		return
	get_cached_path(target)
	target_structure = target
	nav_agent.avoidance_enabled = true
	current_state = State.TRAVELING
	set_waypoint()
	nav_agent.target_position = target_waypoint

func set_waypoint():
	if cached_path_index >= cached_path.size():
		if is_instance_valid(target_structure):
			target_waypoint = target_structure.global_position
	else:
		target_waypoint = cached_path[cached_path_index]

func check_waypoint():
	if global_position.distance_to(target_waypoint) < WAYPOINT_TARGET_RADIUS:
		cached_path_index += 1
		set_waypoint()
		nav_agent.target_position = target_waypoint

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
	if is_instance_valid(target_structure):
		target_position = target_structure.global_position
	else:
		target_position = global_position
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < ARRIVAL_RADIUS:
		current_state = State.SWARMING
		nav_agent.target_position = global_position
		nav_agent.avoidance_enabled = false
		return
	var target_point = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(target_point)
	var new_velocity = direction * stats.speed
	nav_agent.set_velocity(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity

func _swarm_process(delta):
	var target_position
	if is_instance_valid(target_structure):
		target_position = target_structure.global_position
	else:
		target_position = global_position
	var final_force = Vector2.ZERO
	final_force += GRAVITY_WEIGHT * (target_position - global_position).normalized()
	var separation_force = get_separation_force()
	final_force += separation_force * SEPARATION_WEIGHT
	var target_velocity = final_force * stats.speed
	velocity = velocity.lerp(Vector2.ZERO, DRAG_FACTOR * delta)
	velocity = velocity.lerp(target_velocity, turn_speed * delta)
	velocity = velocity.limit_length(stats.speed)
	if velocity.length() < STOP_THRESHOLD_SPEED:
		velocity = Vector2.ZERO


func _physics_process(delta):
	move_and_slide()

func _update_ai():
	match current_state:
		State.SWARMING:
			_swarm_process(AI_timer.wait_time)
		State.TRAVELING:
			_travel_process(AI_timer.wait_time)

func take_damage(amount: int):
	health -= amount
	$HealthBar.value = health
	if health <= 0:
		queue_free()
