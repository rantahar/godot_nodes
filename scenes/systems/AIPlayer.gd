class_name AIPlayer
extends Player

enum State {
	THINKING,
	BUILDING_ECONOMY,
	EXPANDING_NETWORK,
	BUILDING_DEFENSES
}

var current_state = State.THINKING
@onready var decision_timer = $DecisionTimer

func _ready():
	decision_timer.timeout.connect(_on_decision_timer_timeout)

func _on_decision_timer_timeout():
	choose_next_state()
	execute_state_logic()

func choose_next_state():
	if current_state == State.BUILDING_ECONOMY:
		current_state = State.BUILDING_DEFENSES
	else:
		current_state = State.BUILDING_ECONOMY

func execute_state_logic():
	match current_state:
		State.BUILDING_ECONOMY:
			print("AI State: Building Economy")
			try_to_build_mine()
		State.EXPANDING_NETWORK:
			print("AI State: Expanding Network")
		State.BUILDING_DEFENSES:
			print("AI State: Building Defenses")
			try_to_build_cannon()

func try_to_build_mine():
	for grid in grids:
		for expansion in grid.expansions:
			var result = build_structure(expansion, "mine")
			if result:
				return
				
func try_to_build_cannon():
	for grid in grids:
		for expansion in grid.expansions:
			var result = build_structure(expansion, "cannon")
			if result:
				return
