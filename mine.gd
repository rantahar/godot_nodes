class_name Mine
extends Structure

@onready var resource_timer: Timer = $ResourceTimer

signal resources_generated(amount)

func _on_build_timer_timeout():
	super() # Run base logic (e.g., become fully visible)
	resource_timer.start()

func _on_timer_timeout():
	if is_instance_valid(faction):
		emit_signal("resources_generated", 10)
