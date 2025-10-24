extends Node2D

const CELL_SIZE: float = 16.0
const SOURCE_OXYGEN = 10.0
const TERRAFORM_THRESHOLD = 1
const DIFFUSION_STEP_TIME = 0.5
const CORROSION_rate = 0.4

# Visuals
const TERRAFORM_ALPHA: float = 0.35

var terraformed_cells: Dictionary = {}
var terraformer_sources: Array[Terraformer] = []
var source_frontiers: Dictionary = {}
var progress: float = 0

const NEIGHBORS_8 = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]
var rng = RandomNumberGenerator.new()


func _ready():
	EventBus.terraformer_registered.connect(_on_terraformer_registered)
	EventBus.terraformer_unregistered.connect(_on_terraformer_unregistered)

func local_to_map(global_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(global_pos.x / CELL_SIZE),
		floor(global_pos.y / CELL_SIZE)
	)

func map_to_local(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		(float(grid_pos.x) + 0.5) * CELL_SIZE,
		(float(grid_pos.y) + 0.5) * CELL_SIZE
	)

func map_to_local_corner(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		float(grid_pos.x) * CELL_SIZE,
		float(grid_pos.y) * CELL_SIZE
	)

func _on_terraformer_registered(source: Terraformer, player: Player):
	if not is_instance_valid(source) or source in terraformer_sources:
		return
	
	terraformer_sources.append(source)
	var grid_pos = local_to_map(source.global_position)
	source.grid_position = grid_pos
	var cell = terraformed_cells.get(grid_pos)
	
	if not cell:
		terraformed_cells[grid_pos] = TerraCell.new(player, SOURCE_OXYGEN)
	else:
		cell.owner = player
		cell.oxygen = SOURCE_OXYGEN
		cell.source_amount = SOURCE_OXYGEN
	
	var new_frontier: Dictionary = {}
	_add_neighbors_to_frontier(grid_pos, grid_pos, new_frontier, player)
	source_frontiers[source] = new_frontier

func _on_terraformer_unregistered(source: Terraformer):
	if source in terraformer_sources:
		terraformer_sources.erase(source)
	if source in source_frontiers:
		source_frontiers.erase(source)
	
	if terraformed_cells.has(source.grid_pos):
		var cell = terraformed_cells.get(source.grid_pos)

func damage_cell(position: Vector2, amount):
	var coord = map_to_local(position)
	
	if not terraformed_cells.has(position):
		return
	terraformed_cells[position].oxygen -= amount
	if terraformed_cells[position].oxygen >= 0:
		return
	
	terraformed_cells.erase(position)
	
	# Find all unique players adjacent to this new "hole".
	var players: Dictionary = {}
	for offset in NEIGHBORS_8:
		var neighbor_pos = position + offset
		var n_cell: TerraCell = terraformed_cells.get(neighbor_pos)
		if n_cell and n_cell.owner and n_cell.oxygen > TERRAFORM_THRESHOLD:
			players[n_cell.owner] = true

	# Add the destroyed position found players frontiers
	for source in terraformer_sources:
		if not is_instance_valid(source) or not is_instance_valid(source.grid):
			continue
		var player = source.grid.controller
		if players.has(player):
			var frontier: Dictionary = source_frontiers.get(source)
			if frontier != null and not frontier.has(position):
				var dist_sq = source.grid_position.distance_squared_to(position)
				frontier[position] = dist_sq

func get_score_for_player(player: Player) -> int:
	var score = 0
	for pos in terraformed_cells:
		var cell: TerraCell = terraformed_cells[pos]
		if cell.owner == player and cell.oxygen > TERRAFORM_THRESHOLD:
			score += 1
	return score

func _draw():
	var rect_size = Vector2(CELL_SIZE, CELL_SIZE)
	
	for pos in terraformed_cells:
		var cell: TerraCell = terraformed_cells[pos]
		var top_left_corner = map_to_local_corner(pos)
		print(pos, top_left_corner, cell.oxygen)
		
		if cell.owner and cell.oxygen > TERRAFORM_THRESHOLD:
			# var top_left_corner = map_to_local_corner(pos)
			var player_color = cell.owner.color
			
			var alpha = clampf(cell.oxygen / SOURCE_OXYGEN, 0.1, 1.0) * 0.2
			var draw_color = Color(player_color.r, player_color.g, player_color.b, alpha)
			
			draw_rect(Rect2(top_left_corner, rect_size), draw_color)

func _add_neighbors_to_frontier(center_pos: Vector2i, source_grid_pos: Vector2i, frontier: Dictionary, player: Player):
	for offset in NEIGHBORS_8:
		var neighbor_pos = center_pos + offset
		if frontier.has(neighbor_pos):
			continue
			
		var n_cell: TerraCell = terraformed_cells.get(neighbor_pos)
		if n_cell and n_cell.owner == player:
			continue
		
		frontier[neighbor_pos] = source_grid_pos.distance_squared_to(neighbor_pos)

func _process(delta):
	progress += delta
	if progress < DIFFUSION_STEP_TIME:
		return
	else:
		progress -= DIFFUSION_STEP_TIME
	
	if terraformed_cells.is_empty():
		return
	queue_redraw()
	
	for source in terraformer_sources:
		if not is_instance_valid(source):
			_on_terraformer_unregistered(source)
			continue
		
		if not is_instance_valid(source.grid) or not is_instance_valid(source.grid.controller):
			continue
		
		var player = source.grid.controller
		var frontier: Dictionary = source_frontiers.get(source)
		var source_grid_pos = source.grid_position
		
		if not frontier or frontier.is_empty():
			var found_frontier = false
			for other_source in terraformer_sources:
				if other_source == source or not is_instance_valid(other_source):
					continue
				if not is_instance_valid(other_source.grid) or other_source.grid.controller != player:
					continue
				var other_frontier: Dictionary = source_frontiers.get(other_source)
				if other_frontier and not other_frontier.is_empty():
					frontier.merge(other_frontier) 
					found_frontier = true
					break
			if not found_frontier:
				continue
		
		var source_min_dist_sq = INF
		var source_candidates: Array[Vector2i] = []
		var cells_to_prune: Array[Vector2i] = []
		
		for check_pos in frontier:
			var cell: TerraCell = terraformed_cells.get(check_pos)
			
			if cell and cell.owner == player:
				cells_to_prune.append(check_pos)
				continue

			var dist_sq = frontier[check_pos]
			if dist_sq < source_min_dist_sq:
				source_min_dist_sq = dist_sq
				source_candidates = [check_pos]
			elif abs(dist_sq - source_min_dist_sq) < 0.01:
				source_candidates.append(check_pos)
		
		for pos in cells_to_prune:
			frontier.erase(pos)
			_add_neighbors_to_frontier(pos, source_grid_pos, frontier, player)
		
		if source_candidates.is_empty():
			continue
		
		source_candidates.shuffle()
		var candidate = source_candidates[0]
		var target_cell: TerraCell = terraformed_cells.get(candidate)
		if not target_cell:
			terraformed_cells[candidate] = TerraCell.new(player, SOURCE_OXYGEN)
		elif target_cell.owner != player:
			terraformed_cells[candidate].oxygen -= CORROSION_rate * SOURCE_OXYGEN
			if terraformed_cells[candidate].oxygen < 0:
				terraformed_cells.erase(candidate)
