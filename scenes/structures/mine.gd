class_name Mine
extends Structure

var crystal : Crystal = null


func finish_build():
	super()
	$MineAbility.enable()

func apply_stats():
	super()
	$MineAbility.resource_amount = stats["generation_rate"]

func _on_destroyed():
	if is_instance_valid(crystal):
		crystal.has_mine_on_it = false
