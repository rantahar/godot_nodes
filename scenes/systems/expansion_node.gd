class_name ExpansionNode
extends Node2D

@export var player_start_index: int = -1
@export var connected_nodes: Array[ExpansionNode]
@export var main_building: MainBuilding
var crystals: Array[Crystal] = []
var slots: Array[BuildingSlot] = []
var structures: Array[Structure] = []
var units: Array[Unit] = []
var size = 16

@onready var selectionIndicator = $SelectionIndicator

var is_free = true
var grid:
	get:
		if is_instance_valid(main_building):
			return main_building.grid
		else:
			return null

func _ready():
	for child in get_children():
		if child is BuildingSlot:
			slots.append(child)
		if child is Crystal:
			crystals.append(child) 
	print("Found %s build slots and %s crystal locations for %s" % [slots.size(), crystals.size(), self.name])

func append_structure(structure):
	structures.append(structure)

func remove_structure(structure):
	structures.erase(structure)

func register_unit(unit: Unit):
	if unit not in units:
		units.append(unit)

func unregister_unit(unit: Unit):
	units.erase(unit)

func disable_all_structures():
	for structure in structures:
		if structure != main_building:
			structure.disable_abilities()

func enable_all_structures():
	for structure in structures:
		if structure != main_building:
			structure.enable_abilities()

func free_crystal():
	for crystal in crystals:
		if crystal.is_free:
			return crystal
	return null

func free_slot():
	for slot in slots:
		if slot.is_free:
			return slot
	return null

func find_available_slot(structure_data):
	if structure_data.location == "main":
		return self
	elif structure_data.location == "crystal":
		return free_crystal()
	else:
		return free_slot()

func can_build(structure_data, grid):
	if structure_data.location == "main":
		if not grid.can_build_expansion():
			return false
	if structure_data.location not in ["main", "crystal"]:
		if not is_instance_valid(main_building):
			print("No main building")
			return false
		if not main_building.can_build_structure():
			print("Expansion at building capacity")
			return false
	var slot = find_available_slot(structure_data)
	if is_instance_valid(slot):
		return true
	else:
		return false

func build(structure_data, grid):
	var slot = find_available_slot(structure_data)

	var new_node = load(structure_data.scene).instantiate()
	new_node.grid = grid
	new_node.expansion = self
	new_node.slot = slot
	append_structure(new_node)
	slot.add_child(new_node)
	slot.is_free = false
		
	if structure_data.location == "main":
		main_building = new_node
		grid.add_expansion(self)
		if not new_node.is_built:
			assign_main_building_to_constructor(new_node)
	elif is_instance_valid(main_building):
		if not new_node.is_built:
			assign_to_constructor(new_node)

func assign_to_constructor(structure):
	var constructors = find_constructors()
	if constructors.is_empty():
		return
	
	var best_constructor = constructors[0]
	var min_queue_size = best_constructor.construction_ability.queue_size()
	for constructor in constructors:
		if is_instance_valid(constructor) and constructor.is_built:
			var queue_size = constructor.construction_ability.queue_size()
			print("C ", constructor, " ", constructor.construction_ability.build_queue)
			if queue_size < min_queue_size:
				best_constructor = constructor
				min_queue_size = queue_size
	
	best_constructor.construction_ability.add_to_queue(structure)

func find_constructors() -> Array:
	var result = []
	for s in structures:
		if is_instance_valid(s) and s.is_built:
			if s is Builder or s is MainBuilding:
				result.append(s)
	return result

func assign_main_building_to_constructor(main_building: MainBuilding):
	for neighbor in connected_nodes:
		if is_instance_valid(neighbor.main_building):
			neighbor.assign_to_constructor(main_building)
			return
	
	print("Warning: No neighboring constructor found for new main building")
