extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var inputController: Node2D = $InputController
@onready var camera = $Camera2D

# Players
@export var localPlayer: Player
@export var AIPlayers: Array[Player]

@onready var allPlayers = [localPlayer] + AIPlayers

# stats
var start_time_msec: int = 0

var level : Node = null

func _ready():
	level = $LevelContainer/Map
	inputController.level = level
	inputController.camera = camera
	for player in allPlayers:
		player.level = level
		player.player_won.connect(_on_player_won)
	
	var expansions = level.find_children("*", "ExpansionNode")
	for expansion : ExpansionNode in expansions:
		var player_index = expansion.player_start_index
		if player_index >= 0 and player_index < allPlayers.size():
			var controller = allPlayers[player_index]
			var init_grid = Grid.new()
			init_grid.set_level(level)
			init_grid.controller = controller
			controller.grids.append(init_grid)
			controller.build_structure(expansion, "main_building", true)
			var init_main = init_grid.main_buildings[0]
			init_main.level = 1
			init_main.health = init_main.max_health
			init_main.finish_build()
			init_grid.resources_updated.connect(controller._on_resources_updated)
	
	hud.set_player(localPlayer)
	inputController.set_player(localPlayer)

func _on_player_won(player: Player, time_msec: int):
	var time_seconds = (time_msec - start_time_msec) / 1000.0
	print("--- PLAYER WINS: %s ---" % player.name)
	print("Time to win: %.2f seconds" % time_seconds)
	
	# Pausing the game is a simple way to end the match
	get_tree().paused = true
