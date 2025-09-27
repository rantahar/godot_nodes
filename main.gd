extends Node2D

# UI related
const NodeScene = preload("res://node.tscn")
var selected_node = null

@onready var hud: CanvasLayer = $HUD

# Players
@export var localPlayer: Player
@export var AIPlayers: Array[Player]

@onready var allPlayers = [localPlayer] + AIPlayers

var level : Node = null
var node_container : Node = null

func _ready():
	level = $LevelContainer/TestMap
	node_container = level
	
	var factions = level.find_children("*", "Faction")
	for faction : Faction in factions:
		var player_index = faction.player_index
		var controller = allPlayers[player_index]
		faction.controller = controller
		controller.factions.append(faction)
		faction.resources_updated.connect(controller._on_resources_updated)
	
	var nodes = level.find_children("*", "NetworkNode")
	for node : NetworkNode in nodes:
		node.structure_selected.connect(_on_node_selected)
	
	hud.set_player(localPlayer)
	

func create_node(position, faction: Faction, parent_node : NetworkNode):
	var new_node = NodeScene.instantiate()
	new_node.global_position = position
	new_node.faction = faction
	new_node.parent_node = parent_node
	new_node.structure_selected.connect(_on_node_selected)
	new_node.resources_generated.connect(faction._on_node_generated_resources)
	node_container.add_child(new_node)
	return new_node


func _on_node_selected(node):
	if selected_node:
		selected_node.set_selected(false)
	selected_node = node
	selected_node.set_selected(true)

func unselect():
	if selected_node:
		selected_node.set_selected(false)
	selected_node = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if selected_node:
			var faction = selected_node.faction
			
			if not faction:
				# The selected node is not owned by anyone. Just bail.
				return
				
			if faction.controller != localPlayer:
				# Selected node is not owned by player. No command to issue.
				return
			
			if faction.can_afford(faction.NODE_BUILD_COST):
				faction.spend_resources(faction.NODE_BUILD_COST)
				create_node(get_global_mouse_position(), faction, selected_node)

				selected_node.set_selected(false)
				selected_node = null
			else:
				print("Not enough resources!")
				
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		unselect()
