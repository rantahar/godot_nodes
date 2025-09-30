class_name Mine
extends Structure

@onready var resource_timer: Timer = $ResourceTimer

signal resources_generated(amount)

var crystal : Crystal = null

func _ready():
	super()
	if not is_preview:
		crystal = get_parent().get_parent().get_available_crystal_at(global_position)
		crystal.has_mine_on_it = true

func _on_build_timer_timeout():
	super() # Run base logic (e.g., become fully visible)
	resource_timer.start()

func _on_timer_timeout():
	if is_instance_valid(faction):
		emit_signal("resources_generated", 10)

func _on_destroyed():
	if is_instance_valid(crystal):
		crystal.has_mine_on_it = false
