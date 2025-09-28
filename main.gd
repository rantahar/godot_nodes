extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var inputController: Node2D = $InputController

# Players
@export var localPlayer: Player
@export var AIPlayers: Array[Player]

@onready var allPlayers = [localPlayer] + AIPlayers

var level : Node = null
var node_container : Node = null

func _ready():
	level = $LevelContainer/TestMap
	for player in allPlayers:
		player.node_container = level
		player.inputController = inputController
	
	var factions = level.find_children("*", "Faction")
	for faction : Faction in factions:
		var player_index = faction.player_index
		if player_index >= 0 and player_index < allPlayers.size():
			print("player_index ", player_index)
			var controller = allPlayers[player_index]
			faction.controller = controller
			controller.factions.append(faction)
			faction.resources_updated.connect(controller._on_resources_updated)
			controller.build_structure(faction.global_position, "network_node", true)
		else:
			faction.queue_free()
	
	hud.set_player(localPlayer)
	inputController.set_player(localPlayer)
	
