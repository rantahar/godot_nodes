extends Node2D

# UI related
var selected_node = null
var build_mode = null

@onready var hud: CanvasLayer = $HUD

var buildable_structures = {
	"network_node": {
		"scene": preload("res://node.tscn"),
		"cost": 15
	},
	"cannon": {
		"scene": preload("res://cannon.tscn"),
		"cost": 50
	},
	"mine": {
		"scene": preload("res://mine.tscn"),
		"cost": 50
	}
}

const ConnectionScene = preload("res://connection.tscn")

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
		print("player_index ", player_index, allPlayers)
		if player_index >= 0 and player_index < allPlayers.size():
			print("player_index ", player_index)
			var controller = allPlayers[player_index]
			faction.controller = controller
			controller.factions.append(faction)
			faction.resources_updated.connect(controller._on_resources_updated)
			var node_scene = buildable_structures["network_node"]["scene"]
			create_structure(faction.global_position, faction, node_scene, null)
		else:
			faction.queue_free()
	
	hud.set_player(localPlayer)
	

func create_structure(position, faction: Faction, scene, parent_node : NetworkNode):
	print("create_structure")
	var new_node = scene.instantiate()
	new_node.global_position = position
	new_node.faction = faction
	new_node.structure_selected.connect(_on_node_selected)
	node_container.add_child(new_node)
	return new_node

func create_connection(node_a: Structure, node_b: Structure):
	var new_connection = ConnectionScene.instantiate()
	level.add_child(new_connection)
	new_connection.node_a = node_a
	new_connection.node_b = node_b
	node_a.add_connection(new_connection)
	node_b.add_connection(new_connection)
	new_connection.update_line_visuals()

func _on_node_selected(node):
	if selected_node and is_instance_valid(selected_node):
		selected_node.set_selected(false)
		selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
	selected_node = node
	selected_node.structure_destroyed.connect(_on_selected_node_destroyed)
	selected_node.set_selected(true)

func _on_build_button_pressed(mode):
	build_mode = mode

func _on_selected_node_destroyed():
	selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
	selected_node = null

func unselect():
	if is_instance_valid(selected_node):
		selected_node.structure_destroyed.disconnect(_on_selected_node_destroyed)
		selected_node.set_selected(false)
	selected_node = null
	build_mode = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not build_mode:
			return
		
		var mouse_pos = get_global_mouse_position()
		var faction = null
		
		var structure_data = buildable_structures[build_mode]
		if not structure_data:
			return
				
		var objects = level.find_objects_at(mouse_pos, localPlayer.MAX_BUILD_DISTANCE)
		var nearby_network_nodes = []
		for node in objects:
			if node is NetworkNode and node.faction in localPlayer.factions:
				nearby_network_nodes.append(node)
				faction = node.faction
		
		if nearby_network_nodes.is_empty():
			return
		
		if build_mode == "mine":
			var crystal = level.find_available_crystal_at(mouse_pos)
			if crystal and faction.can_afford(structure_data.cost):
				faction.spend_resources(structure_data.cost)
				var new_mine = create_structure(mouse_pos, faction, structure_data.scene, selected_node)
				new_mine.resources_generated.connect(faction._on_node_generated_resources)
				crystal.has_mine_on_it = true
				for neighbor in nearby_network_nodes:
					create_connection(new_mine, neighbor)
			return
				
		var ghost_instance = structure_data.scene.instantiate()
		var collision_shape_node = ghost_instance.find_child("CollisionShape2D")
		var shape_resource = collision_shape_node.shape
		if not level.is_build_location_valid(mouse_pos, shape_resource):
			ghost_instance.queue_free()
			return
		
		if faction.can_afford(structure_data.cost):
			faction.spend_resources(structure_data.cost)
			var structure = create_structure(get_global_mouse_position(), faction, structure_data.scene, selected_node)
			for neighbor in nearby_network_nodes:
				create_connection(structure, neighbor)
		else:
			print("Not enough resources!")
		
		ghost_instance.queue_free()
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		unselect()
