# in input_controller.gd
extends Node2D

# UI related
var selected_node = null
var build_mode = null
var ghost_preview = null

var player: Player = null
var level = null

func set_player(player_node):
	player = player_node

func _on_node_selected(node):
	if selected_node and is_instance_valid(selected_node):
		selected_node.set_selected(false)
		selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
	selected_node = node
	selected_node.structure_destroyed.connect(_on_selected_node_destroyed)
	selected_node.set_selected(true)

func _on_build_button_pressed(mode):
	if is_instance_valid(ghost_preview):
		ghost_preview.queue_free()
		ghost_preview = null
	
	build_mode = mode

	if not build_mode.is_empty():
		var structure_data = player.buildable_structures[build_mode]
		ghost_preview = structure_data.scene.instantiate()
		ghost_preview.set_preview()
		level.add_child(ghost_preview)

func _on_selected_node_destroyed():
	selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
	selected_node = null

func unselect():
	if is_instance_valid(selected_node):
		selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
		selected_node.set_selected(false)
	selected_node = null

func _process(delta):
	if is_instance_valid(ghost_preview):
		var mouse_pos = get_global_mouse_position()
		ghost_preview.global_position = mouse_pos
		
		# Query the level for placement validity
		var collision_shape_node = ghost_preview.find_child("CollisionShape2D")
		var shape_resource = collision_shape_node.shape
		if level.is_build_location_valid(mouse_pos, shape_resource):
			ghost_preview.modulate = Color(0, 1, 0, 0.5) # Green
		else:
			ghost_preview.modulate = Color(1, 0, 0, 0.5) # Red


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not build_mode:
			return
		
		var mouse_pos = get_global_mouse_position()
		player.build_structure(mouse_pos, build_mode)
		ghost_preview.queue_free()
		ghost_preview = null
		build_mode = null
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		unselect()
		ghost_preview.queue_free()
		ghost_preview = null
		build_mode = null
