class_name MainBuildingUpgrade2
extends UpgradeAbility

func _ready() -> void:
	upgrade_name = "main_building_level_2"
	super()

func is_available() -> bool:
	if not parent is MainBuilding:
		return false
	if parent.level == 1:
		return true
	else:
		return false
