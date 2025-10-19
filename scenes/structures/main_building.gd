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
