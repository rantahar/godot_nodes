class_name MainBuildingUpgrade1
extends UpgradeAbility

func is_available() -> bool:
	if not parent is MainBuilding:
		return false
	if parent.level == 0:
		return true
	else:
		return false

func complete_upgrade():
	super()
	parent.level += 1
