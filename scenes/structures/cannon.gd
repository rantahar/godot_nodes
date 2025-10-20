class_name Cannon
extends Structure

const ProjectileScene = preload("res://scenes/projectiles/projectile.tscn")

@onready var turret: Sprite2D = $Sprite2D/Turret
@onready var fire_ability : Ability = $FireAbility

func _ready():
	super()
	var gamedata = GameData
	var stats = gamedata.buildable_structures[building_type]
	
	$FireAbility.projectile_damage = stats["damage"]
	$FireAbility/FireRateTimer.wait_time = stats["fire_rate"]
	$FireAbility.detection_range = stats["range"]

func _process(delta):
	super(delta)
	if is_instance_valid(fire_ability.current_target):
		turret.look_at(fire_ability.current_target.global_position)
