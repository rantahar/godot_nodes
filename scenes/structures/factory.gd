class_name Factory
extends Structure

const UnitScene = preload("res://scenes/units/gun_unit.tscn")

func _on_build_timer_timeout():
	super()
	$UnitProduceAbility.grid = grid
	$UnitProduceAbility.set_rally_point(expansion.global_position)
	$UnitProduceAbility.enable()

func right_click_command(location):
	$UnitProduceAbility.set_rally_point(location)
