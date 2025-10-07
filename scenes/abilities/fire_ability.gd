extends Ability

@export var ProjectileScene: PackedScene
@export var projectile_speed = 100.0
@export var projectile_damage: int = 10
@export var detection_range: float = 4

@onready var detection_area: Area2D = $DetectionArea
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var muzzle: Marker2D = $Muzzle

var targets_in_range: Array[Node2D] = []
var current_target: Node2D = null

func _ready():
	super()
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	var collision_shape = detection_area.get_node("CollisionShape2D")
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = detection_range

func enable():
	super()
	fire_rate_timer.start()

func disable():
	super()
	fire_rate_timer.stop()
	current_target = null
	targets_in_range.clear()

func scan_targets():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var collision_shape = detection_area.get_node("CollisionShape2D")
	query.shape = collision_shape.shape
	query.transform = detection_area.global_transform
	query.collision_mask = 1
	query.collide_with_areas = true
	query.exclude = []
	
	var results = space_state.intersect_shape(query)
		
	var closest_target = null
	var closest_dist_sq = INF
	for result in results:
		var body = result.collider.get_parent().get_parent() # collider -> area -> object
		if body is Structure and body.grid != parent.grid:
			var dist_sq = parent.global_position.distance_squared_to(body.global_position)
			if dist_sq < closest_dist_sq:
				closest_dist_sq = dist_sq
				closest_target = body
	current_target = closest_target

func _on_area_entered(area: Node2D):
	var body = area.get_parent()
	if (body is Structure or body is Unit) and body.grid != parent.grid:
		targets_in_range.append(body)
		if not current_target:
			current_target = body
			
func _on_area_exited(area: Node2D):
	var body = area.get_parent()
	if body in targets_in_range:
		targets_in_range.erase(body)
		if current_target == body:
			find_new_target()

func _on_fire_rate_timer_timeout():
	fire()

func find_new_target():
	if not targets_in_range.is_empty():
		current_target = targets_in_range[0]
	else:
		current_target = null

func fire():
	scan_targets()
	if not is_instance_valid(current_target):
		return
	
	if not charge_ability_cost(ability_cost):
		return
	
	var projectile = ProjectileScene.instantiate()
	projectile.global_position = muzzle.global_position
	projectile.target_position = current_target.global_position
	projectile.speed = projectile_speed
	projectile.damage = projectile_damage
	projectile.grid = parent.grid
	parent.get_parent().add_child(projectile)
