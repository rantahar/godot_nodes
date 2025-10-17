class_name Player
extends Node

signal resources_updated(resources)
signal build_approved(structure_data, position, grids, connections)
signal player_won(player, time_elapsed)

const MAX_BUILD_DISTANCE = 128
const WIN_CONDITION_RESOURCES = 100000
var has_won: bool = false
@export var color: Color = Color.GREEN

var main_buildings: Array[MainBuilding] = []
var grids: Array[Grid] = []
var level: LevelLogic = null

var node_container : Node = null

var resources: Dictionary:
	get:
		var total = {
			"crystal": 0,
			"red_crystal":   0,
			"blue_crystal":  0,
			"green_crystal": 0,
		}
		if grids:
			for grid in grids:
				for type in grid.resources:
					total[type] += grid.resources[type]
		return total

func _ready():
	for grid in grids:
		grid.grid_may_need_split.connect(_on_grid_may_need_split.bind(grid))

func _on_resources_updated():
	emit_signal("resources_updated", resources)
	if not has_won and resources["crystal"] >= WIN_CONDITION_RESOURCES:
		has_won = true
		var time_msec = Time.get_ticks_msec()
		emit_signal("player_won", self, time_msec)

func find_build_grid_for(expansion: ExpansionNode, structure_data):
	if not expansion.is_free:
		if expansion.grid in grids:
			return expansion.grid
		else:
			return null
	elif structure_data.location == "main":
		for connection in expansion.connected_nodes:
			if not connection.is_free and connection.grid in grids:
				return connection.grid

func can_claim_expansion(expansion: ExpansionNode) -> bool:
	if not expansion.is_free:
		return false

	for connection in expansion.connected_nodes:
		if not connection.is_free and connection.grid in grids:
			return true
	return false

func _on_grid_may_need_split(old_grid: Grid):
	var resource_owner = old_grid.get_resource_owner()
	var new_grids = split_grid(old_grid)
	if old_grid.main_buildings.is_empty():
		grids.erase(old_grid)

	for new_grid in new_grids:
		grids.append(new_grid)
		new_grid.grid_may_need_split.connect(_on_grid_may_need_split.bind(new_grid))
		if resource_owner in new_grid.main_buildings:
			new_grid.resources = old_grid.resources

func split_grid(old_grid: Grid) -> Array[Grid]:
	var result: Array[Grid] = []
	var unassigned_mains = old_grid.main_buildings.duplicate()
	
	while not unassigned_mains.is_empty():
		var seed_main = unassigned_mains.pop_front()
		var connected_expansions = find_connected_expansions_from(seed_main.expansion)
		var new_grid = Grid.new()
		new_grid.controller = old_grid.controller
		new_grid.set_map(old_grid.map_node)
		
		for expansion in connected_expansions:
			if expansion.main_building:
				new_grid.add_main_building(expansion.main_building)
				expansion.main_building.grid = new_grid
				unassigned_mains.erase(expansion.main_building)
			
			if expansion in old_grid.expansions:
				old_grid.expansions.erase(expansion)
				new_grid.expansions.append(expansion)
			
			if expansion.main_building:
				for structure in expansion.main_building.structures:
					old_grid.structures.erase(structure)
					new_grid.structures.append(structure)
					structure.grid = new_grid

		new_grid.refresh_connections()
		result.append(new_grid)
	
	return result

func find_connected_expansions_from(start: ExpansionNode) -> Array[ExpansionNode]:
	var result: Array[ExpansionNode] = []
	var to_check = [start]
	
	while not to_check.is_empty():
		var current = to_check.pop_front()
		if current in result:
			continue
		
		result.append(current)
		
		for connected in current.connected_nodes:
			if connected not in result:
				to_check.append(connected)
	
	return result

func build_structure(expansion, build_mode, free = false) -> bool:
	if not build_mode:
		return false
	
	var data = GameData
	var structure_data = data.buildable_structures[build_mode]
	var grid = find_build_grid_for(expansion, structure_data)
	if free:
		grid = grids[0]
	print("grid ", grid)
	
	if not expansion.can_build(structure_data, grid):
		print("Build failed: No valid slots available.")
		return false
	
	if not free:
		if not is_instance_valid(grid):
			print("Build failed: No valid friendly grid.")
		if not grid.can_afford(structure_data.cost):
			print("Build failed: Cannot afford.")
			return false
		else:
			grid.spend_resources(structure_data.cost)
	
	expansion.build(structure_data, grid)
	return true
