extends Ability

@export var UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var rally_point: Marker2D = $RallyPoint
@onready var production_timer: Timer = $ProductionTimer
@onready var production_check_timer: Timer = $ProductionCheckTimer

var faction : Faction = null

func _ready():
	super()
	# Just keep trying to start producing units
	production_check_timer.timeout.connect(produce_unit)

func set_rally_point(location):
	rally_point.global_position = location

func produce_unit():
	if not is_instance_valid(faction):
		return
	if not is_active:
		return
	if not production_timer.is_stopped():
		return
	if charge_ability_cost(ability_cost):
		production_timer.start()

func _on_production_timer_timeout():
	if not is_instance_valid(faction):
		return
	
	var new_unit = UnitScene.instantiate()
	new_unit.faction = faction
	new_unit.global_position = spawn_point.global_position
	
	parent.get_parent().add_child(new_unit)
	new_unit.set_movement_target(rally_point.global_position)
	
	# immediate requeue
	if is_active:
		produce_unit()
