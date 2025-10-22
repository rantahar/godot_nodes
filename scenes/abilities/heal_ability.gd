extends Ability

var heal_rate: float = 5.0
@onready var heal_timer: Timer = $HealTimer

var current_target: Structure = null

func _ready():
	super()
	heal_timer.timeout.connect(_on_heal_timer_timeout)
	heal_timer.start()

func _on_heal_timer_timeout():
	if not is_active:
		return
	
	current_target = find_damaged_structure()
	if current_target:
		current_target.heal(heal_rate)

func find_damaged_structure() -> Structure:
	if not parent.expansion or not parent.expansion:
		return null
	
	var structures = parent.expansion.structures
	for structure in structures:
		if structure.health < structure.max_health:
			return structure
	
	return null

func is_executing() -> bool:
	return is_instance_valid(current_target)

func get_progress() -> Dictionary:
	return {"current": 0.0, "total": 0.0, "in_progress": false}
