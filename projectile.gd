class_name Projectile
extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 10
var faction: Faction = null

func _ready():
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	rotation = velocity.angle()
	global_position += velocity * delta

func _on_area_entered(area: Area2D):
	var body = area.get_parent()
	
	if body is Structure and body.faction != faction:
		body.take_damage(damage)
		# Destroy the projectile on impact
		queue_free()
