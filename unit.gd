class_name Unit
extends CharacterBody2D

@export var stats: UnitStats

var faction: Faction = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	nav_agent.target_position = global_position

func set_movement_target(target_pos: Vector2):
	print("target_pos", target_pos, nav_agent)
	nav_agent.target_position = target_pos

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_position = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * stats.speed
	move_and_slide()
