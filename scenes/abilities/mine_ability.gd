extends Ability

@onready var resource_timer: Timer = $ResourceTimer
signal resources_generated(amount)

@export var resource_amount: int = 10

var crystal : Crystal = null

func enable():
	super()
	resource_timer.start()
	assert(resource_timer.timeout.is_connected(_on_timer_timeout), "Timer not connected")

func disable():
	resource_timer.stop()

func _on_timer_timeout():
	EventBus.emit_signal("resources_generated", resource_amount, parent.grid)
