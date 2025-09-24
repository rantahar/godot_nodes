extends Node2D

# UI related
const NodeScene = preload("res://node.tscn")
var selected_node = null
@onready var resource_label: Label = $Label

# Player stats
var player_resources: int = 0

func _ready():
	create_node(get_viewport().get_visible_rect().size / 2)
	
func create_node(position, parent_node=null):
	var new_node = NodeScene.instantiate()
	new_node.global_position = position
	new_node.parent_node = parent_node
	new_node.node_selected.connect(_on_node_selected)
	new_node.resources_generated.connect(_on_node_resources_generated)
	add_child(new_node)
	return new_node


func _on_node_selected(node):
	if selected_node:
		selected_node.set_selected(false)
	selected_node = node
	selected_node.set_selected(true)
	print(node, " selected")

func unselect():
	if selected_node:
		selected_node.set_selected(false)
	selected_node = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if selected_node:
			# If a node is selected, we are in build mode
			create_node(get_global_mouse_position(), selected_node)
			selected_node.set_selected(false)
			selected_node = null
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		unselect()

func _on_node_resources_generated(amount: Variant) -> void:
	player_resources += amount
	resource_label.text = "Resources: %s" % player_resources
	print("Total Resources: ", player_resources)
