class_name MainBuildingUpgrade2
extends UpgradeAbility

func is_available() -> bool:
	if not parent is MainBuilding:
		return false
	if parent.level == 1:
		return true
	else:
		return false
