extends Unit

func _ready():
	super()
	$FireAbility.projectile_damage = stats["damage"]
	$FireAbility/FireRateTimer.wait_time = stats["fire_rate"]
	$FireAbility.detection_range = stats["range"]
