class_name Structure
extends Node2D

@export var health: int = 100
@export var faction: Node = null

signal structure_selected(node)
signal structure_destroyed(structure)


var connections: Array[Connection] = []

var is_built = false
var is_preview = false
var is_selected = false

func _ready():
	modulate()

func set_preview():
	is_preview = true
	$Area2D.collision_layer = 1 << 31

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
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
	
	var nav_region = get_tree().get_first_node_in_group("nav_region")
	print(nav_region)
	if is_instance_valid(nav_region):
		nav_region.bake_navigation_polygon()

func add_connection(connection: Connection):
	print("add_connection") 
	connections.append(connection)
	print(self, connections, connection)

func _on_destroyed():
	pass 

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		emit_signal("structure_destroyed", self)
		_on_destroyed()
		for connection in connections:
			if is_instance_valid(connection):
				connection.queue_free()
		queue_free()
