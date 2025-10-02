class_name Mine
extends Structure

signal resources_generated(amount)
var crystal : Crystal = null

func _ready():
	super()
	if not is_preview:
		crystal = get_parent().get_available_crystal_at(global_position)
		crystal.has_mine_on_it = true
		$MineAbility.crystal = crystal

func _on_build_timer_timeout():
	super()
	$MineAbility.enable()

func _on_resouce_generated(amount):
	if is_instance_valid(faction):
		emit_signal("resources_generated", amount)

func _on_destroyed():
	if is_instance_valid(crystal):
		crystal.has_mine_on_it = false
