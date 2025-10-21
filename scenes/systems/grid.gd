class_name Grid
extends Node

signal resources_updated()
signal grid_may_need_split()

@export var player_index: int = 0
var controller : Player = null
var main_buildings: Array[MainBuilding] = []
var expansions: Array[ExpansionNode] = []
var connections: Array[ExpansionConnection] = []
var level: Node2D = null

var resources: Dictionary = {
	"crystal": 200,
	"red_crystal": 0,
	"blue_crystal": 0,
	"green_crystal": 0
}

var total_node_capacity: int:
	get:
		var total = 1
		for mb in main_buildings:
			total += mb.max_child_nodes
		print("total_node_capacity ", total)
		return total

func _init():
	EventBus.resources_generated.connect(_on_resources_generated)

func set_level(map: Node2D):
	level = map

func add_resources(type: String, amount: float):
	print("add_resources ", type, amount)
	if resources.has(type):
		resources[type] += amount
	emit_signal("resources_updated")

func has_structure_type(structure_type: String) -> bool:
	for expansion in expansions:
		for structure in expansion.structures:
			if structure.building_type == structure_type:
				return true
	return false

func can_build_expansion() -> bool:
	return expansions.size() < total_node_capacity

func add_main_building(main_building: MainBuilding):
	print("add_main_building")
	main_buildings.append(main_building)
	main_building.grid = self

func remove_main_building(main_building: MainBuilding):
	main_buildings.erase(main_building)
	emit_signal("grid_may_need_split")

func add_expansion(expansion):
	expansions.append(expansion)
	for connection in expansion.connected_nodes:
		if connection in expansions:
			add_connection(connection, expansion)

func remove_expansion(expansion):
	expansions.erase(expansion)

func add_connection(from: ExpansionNode, to: ExpansionNode):
	var connection = ExpansionConnection.new(from, to, get_grid_color())
	connection.z_index = 2
	level.add_child(connection)
	connections.append(connection)

func remove_connection(from: ExpansionNode, to: ExpansionNode):
	for conn in connections:
		var points = conn.points
		if points.size() >= 2:
			# Check both directions
			if (points[0] == from.global_position and points[1] == to.global_position) or \
			   (points[0] == to.global_position and points[1] == from.global_position):
				conn.queue_free()
				connections.erase(conn)
				break 

func get_grid_color() -> Color:
	if controller:
		return controller.color
	return Color.WHITE

func refresh_connections():
	for conn in connections:
		conn.queue_free()
	connections.clear()
	
	for expansion in expansions:
		for connected in expansion.connected_nodes:
			var exists = false
			for conn in connections:
				if (conn.from_expansion == expansion and conn.to_expansion == connected) or \
				   (conn.from_expansion == connected and conn.to_expansion == expansion):
					exists = true
					break
			if not exists:
				add_connection(expansion, connected)

func deactivate_grid():
	for expansion in expansions:
		if expansion.main_building:
			expansion.main_building.toggle_abilities()

func get_resource_owner() -> MainBuilding:
	if main_buildings.is_empty():
		return null
	
	var highest = main_buildings[0]
	for mb in main_buildings:
		if mb.level > highest.level:
			highest = mb
	
	return highest

func can_afford(cost: Dictionary) -> bool:
	for resource_type in cost:
		var required_amount = cost[resource_type]
		if resources.get(resource_type, 0) < required_amount:
			return false
	return true

func _on_resources_generated(resources: Dictionary, target_grid: Grid):
	if target_grid == self:
		for key in resources:
			add_resources(key, resources[key])

func spend_resources(cost: Dictionary):
	for resource_type in cost:
		var amount_to_spend = cost[resource_type]
		if resources.has(resource_type):
			resources[resource_type] -= amount_to_spend
	emit_signal("resources_updated")

func charge_maintenance(cost: Dictionary):
	if can_afford(cost):
		spend_resources(cost)
		return true
	else:
		return false
