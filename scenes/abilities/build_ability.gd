class_name BuildAbility
extends ButtonAbility

@export var structure_to_build: String = ""


func _ready():
	super()
	ability_data = GameData.buildable_structures[structure_to_build]

func execute():
	var input_controller = get_tree().root.get_node("Game/InputController")
	if is_instance_valid(input_controller):
		input_controller._on_build_button_pressed(structure_to_build, parent)
