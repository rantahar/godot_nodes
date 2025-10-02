# in input_controller.gd
extends Node2D

# Camera properties
var camera: Camera2D
@export var pan_speed: float = 500.0
@export var edge_pan_margin: int = 40
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0
@export var camera_bounds: Rect2 = Rect2(0, 0, 1152, 648)

# Selection, player
var selected_objects: Array[Node2D] = []
@onready var selection_box: ColorRect = get_node("/root/Game/HUD/SelectionBox")
var is_dragging = false
var drag_start_pos = Vector2.ZERO
var CLICK_DRAG_THRESHOLD = 10

var build_mode = null
var ghost_preview = null

var player: Player = null
var level = null

func set_player(player_node):
	player = player_node

func _on_build_button_pressed(mode):
	clear_selection()
	
	if is_instance_valid(ghost_preview):
		ghost_preview.queue_free()
		ghost_preview = null
	
	build_mode = mode

	if not build_mode.is_empty():
		var structure_data = player.buildable_structures[build_mode]
		ghost_preview = structure_data.scene.instantiate()
		ghost_preview.set_preview()
		level.add_child(ghost_preview)

func _process(delta):
	if is_instance_valid(ghost_preview):
		var mouse_pos = get_global_mouse_position()
		ghost_preview.global_position = mouse_pos
		var structure_data = player.buildable_structures[build_mode]
		if player.build_location_valid(structure_data, mouse_pos, player.factions, player.MAX_BUILD_DISTANCE):
			ghost_preview.modulate = Color(0, 1, 0, 0.5)
		else:
			ghost_preview.modulate = Color(1, 0, 0, 0.5)
	
	if is_dragging:
		var current_mouse_pos = get_viewport().get_mouse_position()
		selection_box.size = current_mouse_pos - drag_start_pos
		selection_box.position = Vector2(min(drag_start_pos.x, current_mouse_pos.x), min(drag_start_pos.y, current_mouse_pos.y))
		selection_box.size = (drag_start_pos - current_mouse_pos).abs()
	
	if camera:
		var pan_direction = Vector2.ZERO
		pan_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if pan_direction == Vector2.ZERO:
			var mouse_pos = get_viewport().get_mouse_position()
			var viewport_size = get_viewport().get_visible_rect().size
		
			if mouse_pos.x < edge_pan_margin:
				pan_direction.x = -1
			elif mouse_pos.x > viewport_size.x - edge_pan_margin:
				pan_direction.x = 1
			
			if mouse_pos.y < edge_pan_margin:
				pan_direction.y = -1
			elif mouse_pos.y > viewport_size.y - edge_pan_margin:
				pan_direction.y = 1
				
		camera.position += pan_direction * pan_speed * delta / camera.zoom

		var half_viewport = get_viewport().get_visible_rect().size / (2 * camera.zoom)
		camera.position.x = clamp(camera.position.x, camera_bounds.position.x + half_viewport.x, camera_bounds.end.x - half_viewport.x)
		camera.position.y = clamp(camera.position.y, camera_bounds.position.y + half_viewport.y, camera_bounds.end.y - half_viewport.y)


func clear_selection():
	for object in selected_objects:
		if is_instance_valid(object):
			object.selectionIndicator.visible = false
	selected_objects.clear()

func select_units_in_box():
	if not Input.is_key_pressed(KEY_SHIFT):
		clear_selection()
	
	var box_rect = selection_box.get_rect()
	for unit in level.get_children():
		if unit is Unit and unit.faction.controller == player:
			var unit_screen_pos = get_viewport().get_canvas_transform() * unit.global_position
			if box_rect.has_point(unit_screen_pos):
				selected_objects.append(unit)
	
	for object in selected_objects:
		object.selectionIndicator.visible = true

func handle_click_selection():
	var mouse_pos = get_global_mouse_position()
	var results = level.find_objects_at(mouse_pos)
	
	if not Input.is_key_pressed(KEY_SHIFT):
		clear_selection()

	if not results.is_empty():
		var clicked_object = results[0]
		if clicked_object is Structure and not selected_objects.has(clicked_object):
			selected_objects.append(clicked_object)
	
	for object in selected_objects:
		object.selectionIndicator.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_start_pos = get_viewport().get_mouse_position()
			selection_box.position = drag_start_pos
			selection_box.visible = true
		elif is_dragging:
			is_dragging = false
			selection_box.visible = false
			
			if build_mode:
				var mouse_pos = get_global_mouse_position()
				player.build_structure(mouse_pos, build_mode)
				ghost_preview.queue_free()
				ghost_preview = null
				build_mode = null
				return 
			
			var drag_end_pos = get_viewport().get_mouse_position() 
			var drag_vector = drag_end_pos - drag_start_pos
			if drag_vector.length() > CLICK_DRAG_THRESHOLD:
				select_units_in_box()
			else:
				handle_click_selection()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		for object in selected_objects:
			if is_instance_valid(object):
				object.right_click_command(get_global_mouse_position())
		if is_instance_valid(ghost_preview):
			ghost_preview.queue_free()
			ghost_preview = null
		build_mode = null
	
	# camera controls
	if event is InputEventMouseButton and camera:
		var current_zoom_level = camera.zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_zoom_level *= 1.2
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_zoom_level /= 1.2

		current_zoom_level = clamp(current_zoom_level, min_zoom, max_zoom)
		camera.zoom = Vector2(current_zoom_level, current_zoom_level)
