class_name ExpandAbility
extends ButtonAbility

var structure_to_build: String = ""
var structure_data: Dictionary

func _ready():
	super()
	structure_to_build = ability_data["structure_type"]
	if ability_data.has("button_text"):
		button_text = ability_data["button_text"]
	structure_data = GameData.buildable_structures[structure_to_build]

func execute(player: Player):
	var result = player.claim_expansion(parent, structure_to_build)
	return result
	
