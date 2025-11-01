extends Node2D

const CELL_SIZE: float = 16.0
const SOURCE_OXYGEN = 2
const TERRAFORM_THRESHOLD = 1.0
const DIFFUSION_STEP_TIME = 0.5
const MAX_RANGE = 50
const SELF_WEIGHT = 2.0
const SPREAD_RATE = 0.1
const DECAY_RATE = 0.2

# Visuals
const TERRAFORM_ALPHA: float = 0.35

var terraformed_cells: Dictionary = {}
var terraformer_sources: Array[Terraformer] = []
var progress: float = 0

const NEIGHBORS_8 = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]


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
	
	if not terraformed_cells.has(grid_pos):
		terraformed_cells[grid_pos] = TerraCell.new(player, SOURCE_OXYGEN, grid_pos)
	
	for x in range(-MAX_RANGE, MAX_RANGE + 1):
		for y in range(-MAX_RANGE, MAX_RANGE + 1):
			var r = sqrt(x*x + y*y)
			if r <= MAX_RANGE and r > 0:
				var pos = grid_pos + Vector2i(x, y)
				if not terraformed_cells.has(pos):
					terraformed_cells[pos] = TerraCell.new(null, 0.0, pos)
				var cell = terraformed_cells[pos]
				cell.potential[player] = cell.potential.get(player, 0.0) + 1.0 / r

func _on_terraformer_unregistered(source: Terraformer):
	if source not in terraformer_sources:
		return
	
	terraformer_sources.erase(source)
	var grid_pos = source.grid_position
	var player = source.grid.controller
	
	for x in range(-MAX_RANGE, MAX_RANGE + 1):
		for y in range(-MAX_RANGE, MAX_RANGE + 1):
			var r = sqrt(x*x + y*y)
			if r <= MAX_RANGE and r > 0:
				var pos = grid_pos + Vector2i(x, y)
				var cell = terraformed_cells.get(pos)
				if cell:
					cell.potential[player] -= 1.0 / r
					if cell.potential[player] <= 0:
						cell.potential.erase(player)
					if not cell.potential and cell.owner == null:
						terraformed_cells.erase(pos)

func damage_cell(position: Vector2i, amount: float):
	if not terraformed_cells.has(position):
		return
	
	terraformed_cells[position].oxygen -= amount
	if terraformed_cells[position].oxygen <= 0:
		terraformed_cells.erase(position)


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
		
		if cell.owner and cell.oxygen > TERRAFORM_THRESHOLD:
			var top_left_corner = map_to_local_corner(pos)
			var player_color = cell.owner.color
			
			var alpha = clampf(cell.oxygen / SOURCE_OXYGEN, 0.1, 1.0) * 0.2
			var draw_color = Color(player_color.r, player_color.g, player_color.b, alpha)
			
			draw_rect(Rect2(top_left_corner, rect_size), draw_color)

func update_cell(pos: Vector2i):
	var cell = terraformed_cells[pos]
	
	if cell.owner:
		var owner_potential = cell.potential.get(cell.owner, 0.0)
		var enemy_potential = 0.0
		for player in cell.potential:
			if player != cell.owner:
				enemy_potential += cell.potential[player]
		var net_potential = owner_potential - enemy_potential
		if net_potential < 0 and randf() < abs(net_potential) * DECAY_RATE:
			cell.oxygen = 0
			cell.owner = null
			return
	
	var neighbor_counts: Dictionary = {}
	
	for offset in NEIGHBORS_8:
		var neighbor_pos = pos + offset
		var neighbor = terraformed_cells.get(neighbor_pos)
		if neighbor and neighbor.owner and neighbor.oxygen > TERRAFORM_THRESHOLD:
			var player = neighbor.owner
			neighbor_counts[player] = neighbor_counts.get(player, 0) + neighbor.oxygen
	
	if cell.owner:
		neighbor_counts[cell.owner] = neighbor_counts.get(cell.owner, 0) + SELF_WEIGHT * cell.oxygen
	
	var max_count = 0
	var winner: Player = null
	for player in neighbor_counts:
		if neighbor_counts[player] > max_count:
			max_count = neighbor_counts[player]
			winner = player
	
	if winner and cell.potential.has(winner):
		var spread_chance = cell.potential[winner] * max_count * SPREAD_RATE
	
		if randf() < min(1.0, spread_chance):
			cell.owner = winner
			cell.oxygen = SOURCE_OXYGEN

func _process(delta):
	progress += delta
	if progress < DIFFUSION_STEP_TIME:
		return
	progress -= DIFFUSION_STEP_TIME
	
	if terraformed_cells.is_empty():
		return
	
	for pos in terraformed_cells.keys():
		update_cell(pos)
	
	queue_redraw()
