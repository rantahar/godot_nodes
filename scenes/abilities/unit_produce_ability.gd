extends Ability

@export var unit_type = "gun_unit"
@export var UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var rally_point: Marker2D = $RallyPoint
@onready var production_timer: Timer = $ProductionTimer
@onready var production_check_timer: Timer = $ProductionCheckTimer

@export var max_units: int = 4
var active_units: Array[Unit] = []

signal unit_produced(unit_data: Dictionary)
var grid : Grid = null

func _ready():
	super()
	var unit_data =  GameData.buildable_units[unit_type]
	$ProductionTimer.wait_time = unit_data.build_time
	UnitScene = unit_data.scene
	ability_cost = unit_data.cost
	# Just keep trying to start producing units. If disabled, this will fail.
	production_check_timer.timeout.connect(produce_unit)

func set_rally_point(location):
	rally_point.global_position = location

func produce_unit():
	if not is_instance_valid(grid):
		return
	if not is_active:
		return
	if not production_timer.is_stopped():
		return
	if active_units.size() >= max_units:
		return
	if charge_ability_cost(ability_cost):
		production_timer.start()

func _on_production_timer_timeout():
	if not is_instance_valid(grid):
		return

	var unit_data = {
		"scene": UnitScene,
		"grid": grid,
		"position": $SpawnPoint.global_position,
		"init_structure": parent,
		"ability": self,
		"target_structure": parent.expansion.structures[0]
	}
	EventBus.emit_signal("unit_produced", unit_data)
	
	# immediate requeue
	if is_active:
		produce_unit()

func _on_unit_destroyed(unit: Unit):
	active_units.erase(unit)

func _on_unit_created(unit: Unit):
	active_units.append(unit)
	unit.tree_exited.connect(_on_unit_destroyed.bind(unit))
