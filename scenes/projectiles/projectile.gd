class_name Projectile
extends Area2D

var target_position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var speed: float = 100.0
var damage: int = 10

var grid: Grid = null

func _ready():
	area_entered.connect(_on_area_entered)
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed

func _physics_process(delta):
	rotation = velocity.angle()
	global_position += velocity * delta

func _on_area_entered(area: Area2D):
	var body = area.get_parent()

	if (body is Structure or body is Unit) and body.grid != grid:
		body.take_damage(damage)
		# Destroy the projectile on impact
		queue_free()
