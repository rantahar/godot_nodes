extends Ability

@onready var resource_timer: Timer = $ResourceTimer
signal resources_generated(amount)

var crystal : Crystal = null

func enable():
	super()
	assert(resource_timer.timeout.is_connected(_on_timer_timeout), "Timer not connected")
	resource_timer.start()

func disable():
	resource_timer.stop()

func _on_timer_timeout():
	emit_signal("resources_generated", 10)
