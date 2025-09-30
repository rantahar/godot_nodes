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
	if selected_node: 
		unselect()
	
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
		var structure_data = player.buildable_structures[build_mode]
		if player.build_location_valid(structure_data, mouse_pos, player.factions, player.MAX_BUILD_DISTANCE):
			ghost_preview.modulate = Color(0, 1, 0, 0.5)
		else:
			ghost_preview.modulate = Color(1, 0, 0, 0.5)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if selected_node: 
			unselect()
			
		if not build_mode:
			return
		
		var mouse_pos = get_global_mouse_position()
		player.build_structure(mouse_pos, build_mode)
		ghost_preview.queue_free()
		ghost_preview = null
		build_mode = null
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if is_instance_valid(selected_node):
			if selected_node is Factory:
				selected_node.set_rally_point(get_global_mouse_position())
		else:
			if is_instance_valid(ghost_preview):
				ghost_preview.queue_free()
				ghost_preview = null
			build_mode = null
