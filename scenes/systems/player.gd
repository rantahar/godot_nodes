class_name Player
extends Node

signal resources_updated(resources)
signal player_won(player, time_elapsed)

const MAX_BUILD_DISTANCE = 128
const WIN_CONDITION_SCORE = 1000
var has_won: bool = false
@export var color: Color = Color.GREEN

var main_buildings: Array[MainBuilding] = []
var grids: Array[Grid] = []
var level: LevelLogic = null
var completed_upgrades: Array[String] = []

var red_score: float = 0.0
var blue_score: float = 0.0
var green_score: float = 0.0
var gray_score: float = 0.0

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

func _on_score_generated(doctrine: String, amount: float, scoring_player: Player):
	if scoring_player != self:
		return
	
	match doctrine:
		"red":
			red_score += amount
		"blue":
			blue_score += amount
		"green":
			green_score += amount
		"gray":
			gray_score += amount
	
	print(self, " scores:")
	print("red: ", red_score)
	print("blue: ", blue_score)
	print("green: ", green_score)
	print("gray: ", gray_score)
	check_win_condition()

func get_final_score() -> float:
	return max(red_score, blue_score, green_score, gray_score)

func _ready():
	for grid in grids:
		grid.grid_may_need_split.connect(_on_grid_may_need_split.bind(grid))
	EventBus.score_generated.connect(_on_score_generated)

func _on_resources_updated():
	emit_signal("resources_updated", resources)

func check_win_condition():
	if has_won:
		return

	if get_final_score() >= WIN_CONDITION_SCORE:
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

func has_upgrade(upgrade_name: String) -> bool:
	return upgrade_name in completed_upgrades

func register_upgrade(upgrade_name: String):
	print(upgrade_name)
	if upgrade_name not in completed_upgrades:
		completed_upgrades.append(upgrade_name)
	refresh_existing_structures()

func get_structure_stats(structure_type: String) -> Variant:
	var stats = GameData.buildable_structures[structure_type]
	
	if stats.has("damage") and has_upgrade("red_damage_boost"):
		stats["damage"] += 5 
	
	if structure_type == "mine" and has_upgrade("blue_mining_speed"):
		if structure_type == "mine":
			stats["generation_rate"] += 1
	
	return stats

func get_unit_stats(unit_type: String) -> Variant:
	var stats = GameData.buildable_units.get(unit_type, {}).duplicate()
	
	if stats.has("damage") and has_upgrade("red_damage_boost"):
		stats["damage"] = stats["damage"] + 3
	
	return stats

func refresh_existing_structures():
	for grid in grids:
		for expansion in grid.expansions:
			for structure in expansion.structures:
				structure.apply_stats()

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

func claim_expansion(expansion: ExpansionNode, structure_type: String) -> bool:
	if not expansion.is_free:
		print("Claim failed: Expansion not free.")
		return false
	
	var structure_data = GameData.buildable_structures[structure_type]
	
	var grid_to_join = null
	for connection in expansion.connected_nodes:
		if not connection.is_free and connection.grid in grids:
			if is_instance_valid(connection.main_building) and connection.main_building.is_built:
				grid_to_join = connection.grid
				break
			
	if not grid_to_join:
		print("Claim failed: No adjacent friendly *built* grid.")
		return false
	if not grid_to_join.can_build_expansion():
		print("Claim failed: Grid at capacity.")
		return false
	if not expansion.is_free:
		print("Build failed: Expansion not free.")
		return false

	expansion.claim(structure_data, grid_to_join)
	return true

func can_claim_expansion(expansion: ExpansionNode) -> bool:
	if not expansion.is_free:
		return false

	for connection in expansion.connected_nodes:
		if not connection.is_free and connection.grid in grids:
			if is_instance_valid(connection.main_building) and connection.main_building.is_built:
				return true
	return false

func build_structure(expansion, structure_type) -> bool:
	if not structure_type:
		return false
	
	var structure_data = GameData.buildable_structures[structure_type]
	var grid = expansion.grid
	if not is_instance_valid(grid) or grid not in grids:
		print("Build failed: Not a friendly grid.")
		return false
	
	if not expansion.can_build(structure_data, grid):
		print("Build failed: No valid slots available or prereqs not met.")
		return false
	
	expansion.build_structure(structure_data)
	return true
