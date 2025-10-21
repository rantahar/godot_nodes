class_name ButtonAbility
extends Ability

@export var button_icon: Texture2D = null
@export var button_text: String = ""

func _ready() -> void:
	super()
	has_button = true
	is_passive = false

func is_available() -> bool:
	return check_prerequisites()

func execute():
	pass
