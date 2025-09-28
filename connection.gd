class_name Connection
extends Node2D

var node_a: Structure
var node_b: Structure
@onready var line: Line2D = $Line2D

func update_line_visuals():
	if is_instance_valid(node_a) and is_instance_valid(node_b):
		line.points = [node_a.global_position, node_b.global_position]

func get_other_node(this_node: Structure):
	if this_node == node_a:
		return node_b
	elif this_node == node_b:
		return node_a
	return null
