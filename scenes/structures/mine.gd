class_name Mine
extends Structure

var crystal : Crystal = null


func finish_build():
	super()
	$MineAbility.enable()

func _on_destroyed():
	if is_instance_valid(crystal):
		crystal.has_mine_on_it = false
