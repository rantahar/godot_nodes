class_name Factory
extends Structure

const UnitScene = preload("res://scenes/units/gun_unit.tscn")
@onready var rally_point: Marker2D = $RallyPoint

func _on_build_timer_timeout():
	super()
	$UnitProduceAbility.faction = faction
	$UnitProduceAbility.rally_point = rally_point
	$UnitProduceAbility.enable()

func right_click_command(location):
	$UnitProduceAbility.set_rally_point(location)
