extends Ability

@export var ProjectileScene: PackedScene
@export var projectile_speed = 100.0
var projectile_damage: int = 10
@export var detection_range: float = 4

@onready var fire_rate_timer: Timer = $FireRateTimer

var current_target: Node2D = null

func _ready():
	super()
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)

func enable():
	super()

func disable():
	super()
	current_target = null

func scan_targets():
	if parent is Unit and is_instance_valid(parent.current_target):
		var target = parent.current_target
		var target_positon = target.global_position
		var dist = global_position.distance_to(target_positon) - target.size
		print("detection_range ", detection_range, " dist ", dist)
		if dist < detection_range:
			current_target = parent.current_target
			return
	
	if not is_instance_valid(parent.expansion):
		return
	
	var parent_expansion = parent.expansion
	if not is_instance_valid(parent_expansion):
		current_target = null
		return
	
	var potential_targets = parent_expansion.units + parent_expansion.structures
	var closest_target = null
	var closest_dist = detection_range
	var grid = parent.grid
	for target in potential_targets:
		if is_instance_valid(target) and target.grid != grid:
			var dist = global_position.distance_to(target.global_position) - target.size
			if dist < closest_dist:
				closest_dist = dist
				closest_target = target
	current_target = closest_target

func _on_fire_rate_timer_timeout():
	fire()

func fire():
	scan_targets()
	if not is_instance_valid(current_target):
		return
	
	var projectile = ProjectileScene.instantiate()
	projectile.target_position = current_target.global_position
	projectile.speed = projectile_speed
	projectile.damage = projectile_damage
	projectile.grid = parent.grid
	parent.add_child(projectile)
	projectile.global_position = parent.global_position
