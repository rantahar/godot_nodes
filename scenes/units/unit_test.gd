class_name UnitTest
extends Node2D

var target_position: Vector2
var speed = 100
var grid
@onready var selectionIndicator = $SelectionIndicator

func set_movement_target(target_pos: Vector2):
	target_position = target_pos

func right_click_command(location):
	set_movement_target(location)

func _physics_process(delta):
	var direction = global_position.direction_to(target_position)
	global_position += direction*delta*speed
