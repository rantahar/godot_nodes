class_name Factory
extends Structure

func finish_build():
	super()
	progress_ability = $UnitProduceAbility
	$UnitProduceAbility.grid = grid
	$UnitProduceAbility.enable()
