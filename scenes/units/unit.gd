class_name Unit
extends CharacterBody2D

@export var stats: UnitStats
@export var max_health: int = 5
@export var health: int = 5

var grid: Grid = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selectionIndicator = $SelectionIndicator
@onready var separation_area = $SeparationArea
@onready var AI_timer = $AITimer

enum State { SWARMING, TRAVELING }
var target_structure: Structure
var path
var path_index = 0
var current_state = State.SWARMING
var ARRIVAL_RADIUS = 64.0
var SEPARATION_WEIGHT = 10
var GRAVITY_WEIGHT = 5
var DRAG_FACTOR = 10
var STOP_THRESHOLD_SPEED = 10
var turn_speed = 2

var resource = 5

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	var shape_size = $CollisionShape2D.shape.get_rect().size
	$HealthBar.position.y = -shape_size.y-8
	$HealthBar.size.x = shape_size.x
	nav_agent.target_position = global_position
	
	AI_timer.timeout.connect(_update_ai)
	AI_timer.start(randf_range(0.0, AI_timer.wait_time))

func set_movement_target(target: Structure):
	if not target or target == target_structure:
		return
	target_structure = target
	nav_agent.avoidance_enabled = true
	current_state = State.TRAVELING
	var nav_map = get_world_2d().navigation_map
	path = NavigationServer2D.map_get_path(
			nav_map,
			global_position,
			target_structure.global_position,
			true
		)
	
	#var level = get_parent()
	#if not target_structure in level.path_cache:
	#	return
	#path = level.path_cache[target_structure][target]
	#path_index = 0
	#if path and not path.is_empty():
	#	target_structure = target
	#	var cached_path_origin = path[0]
	#	var nav_map = get_world_2d().navigation_map
	#	var full_path = NavigationServer2D.map_get_path(
	#		nav_map,
	#		global_position,
	#		cached_path_origin,
	#		true
	#	)
	#	full_path.resize(full_path.size() - 1)
	#	full_path.append_array(path)
	#	path = full_path

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
	var target_position = target_structure.global_position
	var distance_to_target = global_position.distance_to(target_position)
	if path.is_empty() or path_index >= path.size() or distance_to_target < ARRIVAL_RADIUS:
		current_state = State.SWARMING
		nav_agent.target_position = global_position
		nav_agent.avoidance_enabled = false
		return
	var target_waypoint = path[path_index]
	if global_position.distance_to(target_waypoint) < 5:
		path_index += 1
	if path_index < path.size():
		var direction = global_position.direction_to(target_waypoint)
		var new_velocity = direction * stats.speed
		nav_agent.set_velocity(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity

func _swarm_process(delta):
	var target_position = target_structure.global_position
	var final_force = Vector2.ZERO
	final_force += GRAVITY_WEIGHT * (target_position - global_position).normalized()
	var separation_force = get_separation_force()
	final_force += separation_force * SEPARATION_WEIGHT
	var target_velocity = final_force * stats.speed
	velocity = velocity.lerp(target_velocity, turn_speed * delta)
	velocity = velocity.lerp(Vector2.ZERO, DRAG_FACTOR * delta)
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
