class_name Structure
extends Node2D

signal structure_selected(node)
signal structure_destroyed(structure)

var parent_node = null
var is_built = false
var is_selected = false

@export var faction: Node = null

func _ready():
	if parent_node:
		$Line2D.points = [Vector2.ZERO, parent_node.global_position - self.global_position]
	modulate()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Emit the signal, passing a reference to this node instance.
		emit_signal("structure_selected", self)

func modulate():
	if is_selected:
		$Sprite2D.modulate = Color(0.8, 1.2, 0.8) 
	else:
		$Sprite2D.modulate = Color(1, 1, 1)
	if is_built:
		$Sprite2D.modulate.a = 1.0
	else:
		$Sprite2D.modulate.a = 0.5

func set_selected(is_selected: bool):
	self.is_selected = is_selected
	modulate()

func _on_build_timer_timeout() -> void:
	is_built = true
	modulate()
