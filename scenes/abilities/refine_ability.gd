extends Ability

@onready var timer: Timer = $Timer
signal resources_generated(amount: Dictionary)

@export var resource_generated: String = ""
var resource_amount: int
var ability_cost: Dictionary = {}

func _ready():
	super()
	var data = GameData
	var stats = data.buildable_structures["refinery"]
	resource_amount = stats["resource_amount"]
	ability_cost = stats["resource_cost"]
	timer.wait_time = stats["refine_time"]

func enable():
	super()
	if timer.is_stopped():
		timer.start()
	assert(timer.timeout.is_connected(_on_timer_timeout), "Timer not connected")

func disable():
	timer.stop()

func _on_timer_timeout():
	if charge_ability_cost(ability_cost):
		EventBus.emit_signal("resources_generated", {resource_generated: resource_amount}, parent.grid)
