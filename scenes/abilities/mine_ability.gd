class_name MineAbility
extends Ability

@onready var resource_timer: Timer = $ResourceTimer
signal resources_generated(amount: Dictionary)

var resource_amount: int
var crystal : Crystal = null


func enable():
	super()
	assert(resource_timer.timeout.is_connected(_on_timer_timeout), "Timer not connected")

func _on_timer_timeout():
	EventBus.emit_signal("resources_generated", {"crystal": resource_amount}, parent.grid)
