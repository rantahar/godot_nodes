class_name Unit
extends CharacterBody2D

@export var stats: UnitStats
@export var max_health: int = 5
@export var health: int = 5

var faction: Faction = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selectionIndicator = $SelectionIndicator

var resource = 5

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	var shape_size = $CollisionShape2D.shape.get_rect().size
	$HealthBar.position.y = -shape_size.y-8
	$HealthBar.size.x = shape_size.x
	nav_agent.target_position = global_position

func set_movement_target(target_pos: Vector2):
	nav_agent.target_position = target_pos

func right_click_command(location):
	set_movement_target(location)

func charge_ability_cost(cost) -> bool:
	print(resource, " ", cost) 
	if cost <= resource:
		resource -= cost
		return true
	return false

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * stats.speed
	move_and_slide()

func take_damage(amount: int):
	health -= amount
	$HealthBar.value = health
	if health <= 0:
		queue_free()
