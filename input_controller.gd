# in input_controller.gd
extends Node2D

# UI related
var selected_node = null
var build_mode = null

var player: Player = null

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
	print(mode)
	build_mode = mode

func _on_selected_node_destroyed():
	selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
	selected_node = null

func unselect():
	if is_instance_valid(selected_node):
		selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
		selected_node.set_selected(false)
	selected_node = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not build_mode:
			return
		
		print(build_mode)
		var mouse_pos = get_global_mouse_position()
		player.build_structure(mouse_pos, build_mode)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		unselect()
