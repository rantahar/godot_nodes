class_name Factory
extends Structure

const UnitScene = preload("res://unit.tscn")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var rally_point: Marker2D = $RallyPoint

func _on_build_timer_timeout():
	super()
	$ProductionTimer.start()

func _on_production_timer_timeout():
	if not is_instance_valid(faction):
		return

	var new_unit = UnitScene.instantiate()
	new_unit.faction = self.faction
	new_unit.global_position = spawn_point.global_position
	
	get_parent().add_child(new_unit)
	new_unit.set_movement_target(rally_point.global_position)
	print("Unit produced by ", faction.controller)

func set_rally_point(location):
	rally_point.global_position = location
