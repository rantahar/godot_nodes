extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var inputController: Node2D = $InputController

# Players
@export var localPlayer: Player
@export var AIPlayers: Array[Player]

@onready var allPlayers = [localPlayer] + AIPlayers

# stats
var start_time_msec: int = 0

var level : Node = null

func _ready():
	level = $LevelContainer/TestMap
	inputController.level = level
	for player in allPlayers:
		player.level = level
		player.player_won.connect(_on_player_won)
	
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

func _on_player_won(player: Player, time_msec: int):
	var time_seconds = (time_msec - start_time_msec) / 1000.0
	print("--- PLAYER WINS: %s ---" % player.name)
	print("Time to win: %.2f seconds" % time_seconds)
	
	# Pausing the game is a simple way to end the match
	get_tree().paused = true
