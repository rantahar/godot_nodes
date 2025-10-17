extends Node

var buildable_structures = {
	"main_building": {
		"name": "network_node",
		"scene": preload("res://scenes/structures/main_building.tscn"),
		"cost": {"crystal": 150},
		"build_time": 30.0,
		"max_health": 1500,
		"location": "main"
	},
	"builder": {
		"name": "builder",
		"scene": preload("res://scenes/structures/builder.tscn"),
		"cost": {"crystal": 30},
		"build_time": 5.0,
		"max_health": 200,
		"heal_amount": 5,
		"heal_rate": 5,
		"location": "building_slot"
	},
	"mine": {
		"name": "mine",
		"scene": preload("res://scenes/structures/mine.tscn"),
		"cost": {"crystal": 40},
		"build_time": 5.0,
		"generation_rate": 1,
		"max_health": 150,
		"location": "crystal"
	},
	"cannon": {
		"name": "cannon",
		"scene": preload("res://scenes/structures/cannon.tscn"),
		"cost": {"crystal": 60},
		"build_time": 15.0,
		"max_health": 500,
		"damage": 12,
		"fire_rate": 1.0,
		"location": "building_slot"
	},
	"factory": {
		"name": "factory",
		"scene": preload("res://scenes/structures/factory.tscn"),
		"cost": {"crystal": 80},
		"build_time": 15.0,
		"max_health": 800,
		"supply": 4,
		"location": "building_slot"
	},
	"refinery": {
		"resource_amount": 1,
		"crystal_cost": 1,
		"refine_time": 1,
	},
	"red_refinery": {
		"name": "red refinery",
		"scene": preload("res://scenes/structures/redrefinery.tscn"),
		"cost": {"crystal": 100},
		"build_time": 15.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"blue_refinery": {
		"name": "blue refinery",
		"scene": preload("res://scenes/structures/bluerefinery.tscn"),
		"cost": {"crystal": 100},
		"build_time": 15.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"green_refinery": {
		"name": "green refinery",
		"scene": preload("res://scenes/structures/greenrefinery.tscn"),
		"cost": {"crystal": 100},
		"build_time": 15.0,
		"max_health": 600,
		"location": "building_slot"
	},
}

var buildable_units = {
	"gun_unit": {
		"scene": preload("res://scenes/units/gun_unit.tscn"),
		"cost": {"crystal": 25},
		"build_time": 10.0,
		"max_health": 75,
		"speed": 100,
		"damage": 10,
		"fire_rate": 0.66,
		"supply_cost": 1,
	}
}
