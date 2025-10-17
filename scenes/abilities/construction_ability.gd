extends Ability

var build_queue: Array[Structure] = []
var current_build: Structure = null
var build_progress: float = 0.0

func _ready():
	super()
	set_process(true)

func add_to_queue(structure: Structure):
	build_queue.append(structure)
	print("Added ", structure.building_type, " to build queue. Queue size: ", build_queue.size())

func _process(delta):
	if not is_instance_valid(current_build):
		if build_queue.is_empty():
			current_build = null
			build_progress = 0.0
			return
		current_build = build_queue.pop_front()
		build_progress = 0.0
		print("Started building ", current_build.building_type)
		
	build_progress += delta
	current_build.build_progress = build_progress
	var heal_amount = delta * current_build.max_health / current_build.build_time
	current_build.heal(heal_amount)
	
	if build_progress >= current_build.build_time:
		current_build.finish_build()
		print("Finished building ", current_build.building_type)
		current_build = null
		build_progress = 0.0

func get_progress() -> Dictionary:
	if not is_instance_valid(current_build):
		return {"current": 0.0, "total": 0.0, "in_progress": false}
	return {
		"current": 100*build_progress / current_build.build_time,
		"in_progress": true
	}

func is_executing():
	return is_instance_valid(current_build)
