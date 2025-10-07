extends Ability

@export var UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var rally_point: Marker2D = $RallyPoint
@onready var production_timer: Timer = $ProductionTimer
@onready var production_check_timer: Timer = $ProductionCheckTimer

signal unit_produced(unit_data: Dictionary)
var grid : Grid = null

func _ready():
	super()
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
		"target_structure": parent.expansion.structures[0]
	}
	EventBus.emit_signal("unit_produced", unit_data)
	
	# immediate requeue
	if is_active:
		produce_unit()
