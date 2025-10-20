class_name UpgradeAbility
extends ButtonAbility

@export var upgrade_name: String = ""

var is_upgrading = false
var upgrade_cost = {}
var upgrade_progress = 0.0
var upgrade_time = 10.0

func _ready():
	super()
	is_passive = true # uprgade runs with timer
	ability_data = GameData.upgrades[upgrade_name]
	upgrade_cost = ability_data.cost
	upgrade_time = ability_data.build_time

func execute():
	print("clicked")
	if not charge_ability_cost(upgrade_cost):
		return false
	
	is_upgrading = true
	upgrade_progress = 0.0
	return true
	
func _process(delta):
	if is_upgrading:
		upgrade_progress += delta
		if upgrade_progress >= upgrade_time:
			complete_upgrade()

func complete_upgrade():
	is_upgrading = false
	upgrade_progress = 0.0

func is_executing():
	return is_upgrading

func get_progress() -> Dictionary:
	if not is_upgrading:
		return {"current": 0.0, "total": 0.0, "in_progress": false}
	return {
		"current": 100 * upgrade_progress / upgrade_time,
		"in_progress": true
	}
