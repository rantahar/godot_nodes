extends Node2D

signal node_selected(node)
signal resources_generated(amount)
var parent_node = null
var produce_resource = false
var is_built = false
var is_selected = false

func _ready():
	if parent_node:
		$Line2D.points = [Vector2.ZERO, parent_node.global_position - self.global_position]
	modulate()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Emit the signal, passing a reference to this node instance.
		emit_signal("node_selected", self)
		print(self, "clicked")

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

func check_for_crystal_proximity():
	var overlapping_areas: Array[Area2D] = $Area2D.get_overlapping_areas()
	print(overlapping_areas)
	
	for area in overlapping_areas:
		if area.get_parent().is_in_group("crystals"):
			produce_resource = true
			print("Node produces resource. Starting resource timer.")
			$Timer.start() 
			break


func _on_timer_timeout() -> void:
	if produce_resource:
		print(self, " resource timer ")
		# If the timer fires and this node is productive, emit a signal with the resource amount.
		emit_signal("resources_generated", 5) # Generate 5 resources per cycle


func _on_build_timer_timeout() -> void:
	is_built = true
	print(self, " Build complete. Checking for resources.")
	check_for_crystal_proximity()
	modulate()
