class_name ButtonAbility
extends Ability

@export var action_name: String = ""
@export var action_icon: Texture2D = null

var ability_data: Dictionary

func _ready() -> void:
	super()
	has_button = true
	is_passive = false

func is_available() -> bool:
	return check_prerequisites()

func check_prerequisites() -> bool:
	if not ability_data:
		return false
	var prereqs = ability_data.get("prerequisites", {})
	if prereqs.has("upgrade"):
		var player = parent.grid.controller
		if not player.has_upgrade(prereqs["upgrade"]):
			return false
	if prereqs.has("requires_structure"):
		var grid = parent.grid
		if not grid.has_structure_type(prereqs["requires_structure"]):
			return false
	return true

func execute():
	pass
