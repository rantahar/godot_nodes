class_name Structure
extends Node2D

@export var health: int = 100
@export var faction: Node = null

signal structure_selected(node)
signal structure_destroyed(structure)


var connections: Array[NetworkNode] = []

var is_built = false
var is_preview = false
var is_selected = false

func _ready():
	modulate()

func set_preview():
	is_preview = true
	$Area2D.collision_layer = 1 << 31

func setup_connections(nodes_to_connect: Array[NetworkNode]):
	connections = nodes_to_connect
	if connections.is_empty():
		return
		
	var points = PackedVector2Array()
	for connected_node in connections:
		points.append(Vector2.ZERO)
		points.append(connected_node.global_position - self.global_position)
		

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Emit the signal, passing a reference to this node instance.
		emit_signal("structure_selected", self)

func modulate():
	if is_preview:
		return
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

func add_connection(connection: Connection):
	connections.append(connection)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		emit_signal("structure_destroyed", self)
		queue_free()
