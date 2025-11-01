class_name ExpandingAIPlayer
extends Player

enum State {
	EXPANDING_NETWORK,
	BUILDING_MINES,
	BUILDING_FACTORIES
}

var current_state = State.EXPANDING_NETWORK
@onready var decision_timer = $DecisionTimer

func _ready():
	decision_timer.timeout.connect(_on_decision_timer_timeout)

func _on_decision_timer_timeout():
	choose_next_state()
	execute_state_logic()

func choose_next_state():
	var n_mains = 0
	for grid in grids:
		n_mains += grid.main_buildings.size()
	
	if n_mains < 2:
		current_state = State.EXPANDING_NETWORK
		return

	var n_mines = 0
	for grid in grids:
		for expansion in grid.expansions:
			for structure in expansion.structures:
				if structure.building_type == "mine":
					n_mines += 1
	
	if n_mines < 6:
		current_state = State.BUILDING_MINES
		return

	else:
		print("Factories ", n_mains, n_mines)
		current_state = State.BUILDING_FACTORIES
		return


func execute_state_logic():
	match current_state:
		State.EXPANDING_NETWORK:
			print("AI State: Expanding Network")
			try_to_expand()
		State.BUILDING_MINES:
			print("AI State: Building Mines")
			try_to_build_mine()
		State.BUILDING_FACTORIES:
			print("AI State: Building Factories")
			try_to_build_factory()

func try_to_expand():
	var n_mains = 0
	for grid in grids:
		n_mains += grid.main_buildings.size()
	if n_mains > 3:
		return

	for grid in grids:
		for expansion in grid.expansions:
			for neighbour in expansion.connected_nodes:
				if neighbour.is_free:
					var result = neighbour.execute_button_ability(
						"build_main_building",
						self
					)
					if result:
						return

func try_to_build_mine():
	for grid in grids:
		for main in grid.main_buildings:
			print("main ", main)
			var result = main.execute_button_ability(
				"build_mine",
				self
			)
			print("mine ", result)
			if result:
				return

func try_to_build_factory():
	for grid in grids:
		for main in grid.main_buildings:
			var result = main.execute_button_ability(
				"build_factory",
				self
			)
			if result:
				return
