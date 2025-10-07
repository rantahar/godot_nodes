class_name BuildAbility
extends Ability

@export var structure_to_build: String = ""
@export var action_name: String = ""
@export var action_icon: Texture2D = null

func execute():
	var input_controller = get_tree().root.get_node("Game/InputController")
	if is_instance_valid(input_controller):
		input_controller._on_build_button_pressed(structure_to_build, parent)
