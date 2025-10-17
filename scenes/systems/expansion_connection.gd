class_name ExpansionConnection
extends Line2D

var from_expansion: ExpansionNode
var to_expansion: ExpansionNode

func _init(from: ExpansionNode, to: ExpansionNode, color: Color):
	from_expansion = from
	to_expansion = to
	width = 3.0
	default_color = color
	update_points()

func update_points():
	if is_instance_valid(from_expansion) and is_instance_valid(to_expansion):
		points = [from_expansion.global_position, to_expansion.global_position]
