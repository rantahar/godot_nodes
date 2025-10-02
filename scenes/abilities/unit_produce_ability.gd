extends Ability

@export var UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var rally_point: Marker2D = $RallyPoint

var faction : Faction = null

func enable():
	super()
	$ProductionTimer.start()

func set_rally_point(location):
	rally_point.global_position = location

func _on_production_timer_timeout():
	if not is_instance_valid(faction):
		return
	
	if not charge_ability_cost(ability_cost):
		return
	
	var new_unit = UnitScene.instantiate()
	new_unit.faction = faction
	new_unit.global_position = spawn_point.global_position
	
	parent.get_parent().add_child(new_unit)
	new_unit.set_movement_target(rally_point.global_position)
