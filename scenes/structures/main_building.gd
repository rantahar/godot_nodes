class_name MainBuilding
extends Structure

@export var level: int = 0
var max_child_nodes: int:
	get: return 2*level
var max_structures: int:
	get: return 2+2*level

@onready var construction_ability = $ConstructionAbility


func _ready():
	super()
	progress_ability =$ConstructionAbility
	grid.add_main_building(self)
	_add_build_abilities()

func _add_build_abilities():
	var buildables = ["build_mine", "build_cannon", "build_laboratory",
					  "build_factory",
					  "build_green_refinery", "build_blue_refinery", 
					  "build_red_refinery", "build_terraformer",
					  "build_space_port", "build_shield",
					  "build_shelter" ]
	
	for ability_name in buildables:
		var ability = BuildAbility.new()
		ability.ability_name = ability_name
		add_child(ability)


func can_build_structure():
	var structures = expansion.structures
	var non_mine_structures = structures.filter(func(s): return not s is Mine)
	return non_mine_structures.size() < max_structures

func destroy():
	for connected in expansion.connected_nodes:
		grid.remove_connection(expansion, connected)
	grid.remove_main_building(self)
	grid.remove_expansion(expansion)
	expansion.main_building = null
	super()
