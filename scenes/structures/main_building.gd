class_name MainBuilding
extends Structure

@export var level: int = 0
var max_child_nodes: int:
	get: return 2*level
var max_structures: int:
	get: return 2+2*level

@onready var construction_ability = $ConstructionAbility
var structures: Array[Structure] = []


func _ready():
	super()
	progress_ability =$ConstructionAbility
	grid.add_main_building(self)

func can_build_structure():
	var non_mine_structures = structures.filter(func(s): return not s is Mine)
	return non_mine_structures.size() < max_structures

func add_structure(structure):
	structures.append(structure)
	if not structure.is_built:
		assign_to_constructor(structure)
	structure.grid.controller = grid.controller

func assign_to_constructor(structure):
	var constructors = find_constructors()
	if constructors.is_empty():
		return
	
	var best_constructor = constructors[0]
	var min_queue_size = best_constructor.construction_ability.build_queue.size()
	for constructor in constructors:
		if is_instance_valid(constructor) and constructor.is_built:
			var queue_size = constructor.construction_ability.build_queue.size()
			if queue_size < min_queue_size:
				best_constructor = constructor
				min_queue_size = queue_size
	
	best_constructor.construction_ability.add_to_queue(structure)

func find_constructors() -> Array:
	var result = []
	if construction_ability:
		result.append(self)
	for s in structures:
		if is_instance_valid(s) and s.is_built:
			if s is Builder:
				result.append(s)
	print(structures, " ", result)
	return result

func remove_structure(structure):
	structures.erase(structure)

func find_next_unfinished_building() -> Structure:
	for structure in structures:
		if not structure.is_built:
			print("Starting to build ", structure.building_type)
			return structure
	return null

func destroy():
	for connected in expansion.connected_nodes:
		grid.remove_connection(expansion, connected)
	grid.remove_main_building(self)
	grid.remove_expansion(expansion)
	expansion.main_building = null
	super()

func _on_structure_destroyed(structure):
	remove_structure(structure)
