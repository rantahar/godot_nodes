extends Ability

@export var unit_type = "gun_unit"
@export var UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var production_check_timer: Timer = $ProductionCheckTimer

@export var max_units: int = 4
var active_units: Array[Unit] = []

signal unit_produced(unit_data: Dictionary)
var grid : Grid = null
var production_time: int
var production_progress: float = 0
var is_producing: bool = false

func _ready():
	super()
	var unit_data =  GameData.buildable_units[unit_type]
	UnitScene = unit_data.scene
	ability_cost = unit_data.cost
	production_time = unit_data.build_time

func _process(delta):
	if not is_active:
		return
	
	if is_producing:
		production_progress += delta
		if production_progress >= production_time:
			is_producing = false
			production_progress = 0.0
			production_complete()
	else:
		produce_unit()

func produce_unit():
	if not is_instance_valid(grid):
		return
	if not is_active:
		return
	if is_producing:
		return
	if active_units.size() >= max_units:
		return
	if charge_ability_cost(ability_cost):
		is_producing = true
		production_progress = 0.0

func production_complete():
	if not is_instance_valid(grid):
		return

	var unit_data = {
		"scene": UnitScene,
		"grid": grid,
		"position": $SpawnPoint.global_position,
		"init_structure": parent,
		"ability": self,
		"target_structure": parent.expansion.main_building
	}
	EventBus.emit_signal("unit_produced", unit_data)

func _on_unit_destroyed(unit: Unit):
	active_units.erase(unit)

func _on_unit_created(unit: Unit):
	active_units.append(unit)
	unit.tree_exited.connect(_on_unit_destroyed.bind(unit))

func is_executing():
	return is_producing

func get_progress() -> Dictionary:
	var progress = 100 - 100 * production_progress / production_time 
	return {
		"current": progress,
		"in_progress": true
	}
