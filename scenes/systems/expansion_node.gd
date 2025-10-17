class_name ExpansionNode
extends Node2D

@export var player_start_index: int = -1
@export var connected_nodes: Array[ExpansionNode]
@export var main_building: MainBuilding
var crystals: Array[Crystal] = []
var slots: Array[BuildingSlot] = []

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

	var new_node = structure_data.scene.instantiate()
	new_node.grid = grid
	new_node.expansion = self
	new_node.slot = slot
	slot.add_child(new_node)
	slot.is_free = false
	
	if structure_data.location == "main":
		main_building = new_node
		grid.add_expansion(self)
		if not new_node.is_built:
			assign_main_building_to_constructor(new_node)
	elif is_instance_valid(main_building):
		main_building.add_structure(new_node)
	
	new_node.structure_destroyed.connect(main_building._on_structure_destroyed)

func assign_main_building_to_constructor(main_building: MainBuilding):
	for neighbor in connected_nodes:
		if is_instance_valid(neighbor.main_building):
			neighbor.main_building.assign_to_constructor(main_building)
			return
	
	print("Warning: No neighboring constructor found for new main building")
