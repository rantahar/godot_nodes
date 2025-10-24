class_name Ability
extends Node2D

var parent: Node2D
var is_active = true
var is_passive = true
var has_button = false
var ability_data: Dictionary

@export var ability_name: String = ""

# for active abilities that have a cost. We split the cost into individual
# packets that get spent as the ability proceeds.
var cost_packets: Array[String] = []
var packets_charged: int = 0

func _ready():
	parent = get_parent()
	ability_data = GameData.abilities.get(ability_name, {})

func check_prerequisites() -> bool:
	if not ability_data or not ability_data.has("prerequisites"):
		return true
	
	var prereqs = ability_data.get("prerequisites", {})
	if prereqs.has("upgrade"):
		var player = parent.grid.controller if parent.grid else null
		if not player or not player.has_upgrade(prereqs["upgrade"]):
			return false
	
	if prereqs.has("structure"):
		var grid = parent.grid if parent.grid else null
		if not grid or not grid.has_structure_type(prereqs["structure"]):
			return false
	
	return true

func enable():
	is_active = true
	set_process(true)
	for child in get_children():
		if child is Timer:
			if child.is_stopped():
				child.start()

func disable():
	is_active = false
	set_process(false)
	for child in get_children():
		if child is Timer:
			child.stop()

func toggle():
	# Some abilites can be toggled using the toggle UI button
	pass

func is_executing() -> bool:
	return false

func can_execute() -> bool:
	return false

func calculate_cost_packets(cost: Dictionary):
	cost_packets.clear()
	var added: Dictionary = {}
	var total_packets = 0
	
	for resource_type in cost.keys():
		added[resource_type] = 0
		total_packets += cost[resource_type]
	
	for i in range(total_packets):
		var best_resource = ""
		var lowest_percent = 2.0
		
		for resource_type in cost.keys():
			if added[resource_type] < cost[resource_type]:
				var percent = float(added[resource_type]) / cost[resource_type]
				if percent < lowest_percent:
					lowest_percent = percent
					best_resource = resource_type
		
		cost_packets.append(best_resource)
		added[best_resource] += 1

func charge_cost_up_to(progress_fraction: float):
	if cost_packets.is_empty():
		return true
	
	var packets_due = floor(progress_fraction * cost_packets.size())
	while packets_charged < packets_due:
		var resource_type = cost_packets[packets_charged]
		if parent.charge_ability_cost({resource_type: 1}):
			packets_charged += 1
		else:
			return false
	return true

func charge_ability_cost(cost):
	return parent.charge_ability_cost(cost)
