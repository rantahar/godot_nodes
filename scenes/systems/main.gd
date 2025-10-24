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
@onready var game_timer: Timer = $GameTimer

var level : Node = null

func _ready():
	level = $LevelContainer/Map
	inputController.set_level(level)
	inputController.set_camera(camera)
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
			var structure_data = GameData.buildable_structures["main_building"]
			expansion.claim(structure_data, init_grid)
			
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

func _on_game_timer_timeout():
	get_tree().paused = true
	var final_scores = []
	for player in allPlayers:
		final_scores.append({"player": player, "score": player.get_final_score()})
	
	final_scores.sort_custom(func(a, b): return a.score > b.score)
	var winner = final_scores[0].player
	print("--- GAME OVER (Time) ---")
	print("Winner: %s with %.2f points" % [winner.name, final_scores[0].score])
