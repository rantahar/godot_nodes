class_name ExpansionNode
extends Node2D

@export var connected_nodes: Array[ExpansionNode]
var crystals: Array[Crystal] = []
var slots: Array[BuildingSlot] = []
@export var structures: Array[Structure]
@export var player_start_index: int = -1

@onready var selectionIndicator = $SelectionIndicator

var is_free = true
var grid: Grid = null

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

func can_build(structure_data):
	print("can_build ", structure_data)
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
	structures.append(new_node)
	slot.add_child(new_node)
	slot.is_free = false
	
	if structure_data.location == "main":
		self.grid = grid
		grid.expansions.append(self)
		
	new_node.structure_destroyed.connect(grid._on_structure_destroyed)
