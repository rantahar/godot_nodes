class_name MainBuildingUpgrade
extends UpgradeAbility

@export var level = 0

func is_available() -> bool:
	var available = super()
	if not parent is MainBuilding:
		return false
	if parent.level == level:
		return available
	else:
		return false

func complete_upgrade():
	super()
	parent.level += 1
