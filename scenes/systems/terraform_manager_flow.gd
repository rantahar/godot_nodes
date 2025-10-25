extends Node2D

const SOURCE_OXYGEN = 100.0
const CELL_SIZE: float = 16.0
const DIFFUSION_RATE = 0.5
const DIFFUSION_STEP_TIME = 0.2
const CORROSION_RATE = 0.6
const TERRAFORM_THRESHOLD = 1.0
const FLIP_THRESHOLD = 0.0

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
	var cell = terraformed_cells.get(grid_pos)
	
	if not cell:
		terraformed_cells[grid_pos] = TerraCell.new(player, SOURCE_OXYGEN, SOURCE_OXYGEN)
	else:
		cell.owner = player
		cell.oxygen = SOURCE_OXYGEN
		cell.source_amount = SOURCE_OXYGEN

func _on_terraformer_unregistered(source: Terraformer):
	if source in terraformer_sources:
		terraformer_sources.erase(source)
	
	if terraformed_cells.has(source.grid_pos):
		var cell = terraformed_cells.get(source.grid_pos)
		cell.is_source = false

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
		
		if cell.owner and cell.oxygen > TERRAFORM_THRESHOLD:
			# var top_left_corner = map_to_local_corner(pos)
			var player_color = cell.owner.color
			
			var alpha = clampf(cell.oxygen / TERRAFORM_THRESHOLD, 0.1, 1.0) * 0.3
			var draw_color = Color(player_color.r, player_color.g, player_color.b, alpha)
			
			draw_rect(Rect2(top_left_corner, rect_size), draw_color)

func _process(delta):
	progress += delta
	if progress < DIFFUSION_STEP_TIME:
		return
	else:
		progress -= DIFFUSION_STEP_TIME
		queue_redraw()
		
	if terraformed_cells.is_empty():
		return
	
	var new_cells = terraformed_cells.duplicate(true)
	for pos in terraformed_cells:
		var cell: TerraCell = terraformed_cells[pos]
		
		if cell.oxygen > 1:
			var pressure = cell.oxygen / SOURCE_OXYGEN
			var oxygen_to_push_total = cell.oxygen * DIFFUSION_RATE * pressure
			var push_per_neighbor = oxygen_to_push_total / 8.0
			
			for n_offset in NEIGHBORS_8:
				var n_pos = pos + n_offset
				var neighbor_cell: TerraCell = terraformed_cells.get(n_pos)
				var current_push = push_per_neighbor
				if current_push < 1:
					continue
				if n_offset.x != 0 and n_offset.y != 0:
					current_push *= 0.7
				new_cells[pos].oxygen -= current_push
				if not neighbor_cell:
					new_cells[n_pos] = TerraCell.new(cell.owner, current_push)
				elif neighbor_cell.owner == cell.owner:
					new_cells[n_pos].oxygen += current_push
				else:
					new_cells[n_pos].oxygen -= CORROSION_RATE * push_per_neighbor
		
		if cell.source_amount > 0:
			new_cells[pos].oxygen += cell.source_amount
	
	for pos in terraformed_cells:
		var cell: TerraCell = new_cells[pos]
		if cell.oxygen < 0.0:
			new_cells.erase(pos)
	
	terraformed_cells = new_cells
	
	for source in terraformer_sources:
		var score = get_score_for_player(source.grid.controller)
		print("score: ", score)

func get_strongest_neighbor_owner(pos: Vector2i) -> Player:
	var strongest_owner: Player = null
	var max_oxygen: float = -1.0
	
	for n_offset in NEIGHBORS_8:
		var n_pos = pos + n_offset
		var neighbor_cell: TerraCell = terraformed_cells.get(n_pos)
		
		if neighbor_cell and neighbor_cell.oxygen > max_oxygen:
			max_oxygen = neighbor_cell.oxygen
			strongest_owner = neighbor_cell.owner
			
	return strongest_owner
