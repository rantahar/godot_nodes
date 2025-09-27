class_name Cannon
extends Structure

@onready var turret: Sprite2D = $Sprite2D/Turret
@onready var targeting_area: Area2D = $TargetingArea

var targets_in_range: Array[Node2D] = []
var current_target: Node2D = null

func _ready():
	super()
	targeting_area.area_entered.connect(_on_body_entered)
	targeting_area.area_exited.connect(_on_body_exited)
	
	call_deferred("find_new_target")

func _process(delta):
	if is_instance_valid(current_target):
		turret.look_at(current_target.global_position)
	else:
		find_new_target()

func _on_body_entered(area: Node2D):
	var body = area.get_parent()
	if body is Structure and body.faction != self.faction:
		targets_in_range.append(body)
		if not current_target:
			current_target = body
			
func _on_body_exited(body: Node2D):
	if body in targets_in_range:
		targets_in_range.erase(body)
		if current_target == body:
			find_new_target()

func _on_build_timer_timeout():
	super()
	scan_for_initial_targets()

func find_new_target():
	if not targets_in_range.is_empty():
		current_target = targets_in_range[0]
	else:
		current_target = null

func scan_for_initial_targets():
	var initial_areas = targeting_area.get_overlapping_areas()
	for area in initial_areas:
		_on_body_entered(area)
