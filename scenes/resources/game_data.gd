extends Node


var abilities = {
	"refine": {
		"resource_amount": 2,
		"resource_cost": {"crystal": 2},
		"refine_time": 1,
	},
	# upgrades including cost
	"main_building_level_1": {
		"name": "main_building_level_1",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"cost": {"crystal": 50},
		"build_time": 30.0,
		"prerequisites": {},
	},
	"main_building_level_2": {
		"name": "main_building_level_2",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"cost": {"crystal": 100},
		"build_time": 30.0,
		"prerequisites": {},
	},
	"blue_mining_speed": {
		"name": "blue_mining_speed",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"cost": {"crystal": 20, "blue_crystal": 10},
		"build_time": 1.0,
		"prerequisites": {
			"structure": "blue_refinery"
		},
	},
	"red_damage_boost": {
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"prerequisites": {
			"requires_structure": "red_refinery"
		}
	},
	# structures, only prerequisites here
	"build_main_building": {
		"structure_type": "main_building"
	},
	"build_mine": {
		"structure_type": "mine"
	},
	"build_cannon": {
		"structure_type": "cannon"
	},
	"build_factory": {
		"prerequisites": {
			"upgrade": "main_building_level_2"
		},
		"structure_type": "factory"
	},
	"build_red_refinery": {
		"structure_type": "red_refinery"
	},
	"build_blue_refinery": {
		"structure_type": "blue_refinery"
	},
	"build_green_refinery": {
		"structure_type": "green_refinery"
	},
	"build_terraformer": {
		"prerequisites": {
			"structure": "green_refinery"
		},
		"structure_type": "terraformer"
	}
}

var buildable_structures = {
	"main_building": {
		"name": "network_node",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/main_building.tscn",
		"cost": {"crystal": 300},
		"build_time": 30.0,
		"max_health": 1500,
		"location": "main"
	},
	"mine": {
		"name": "mine",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/mine.tscn",
		"cost": {"crystal": 10},
		"build_time": 1.0,
		"generation_rate": 2,
		"max_health": 150,
		"location": "crystal"
	},
	"cannon": {
		"name": "cannon",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/cannon.tscn",
		"cost": {"crystal": 120},
		"build_time": 15.0,
		"max_health": 500,
		"damage": 12,
		"fire_rate": 1.0,
		"range": 512,
		"location": "building_slot"
	},
	"factory": {
		"name": "factory",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/factory.tscn",
		"cost": {"crystal": 150},
		"build_time": 15.0,
		"max_health": 800,
		"supply": 4,
		"location": "building_slot"
	},
	"red_refinery": {
		"name": "red refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/redrefinery.tscn",
		"cost": {"crystal": 200},
		"build_time": 15.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"blue_refinery": {
		"name": "blue refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/bluerefinery.tscn",
		"cost": {"crystal": 200},
		"build_time": 1.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"green_refinery": {
		"name": "green refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/greenrefinery.tscn",
		"cost": {"crystal": 20},
		"build_time": 1.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"terraformer": {
		"name": "Terraformer",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Green/Default/button_round_flat.png"),
		"scene": "res://scenes/structures/terraformer.tscn",
		"cost": {"crystal": 40, "green_crystal": 5},
		"build_time": 3.0,
		"max_health": 1000,
		"location": "building_slot"
	},
}

var buildable_units = {
	"gun_unit": {
		"scene": "res://scenes/units/gun_unit.tscn",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
		"cost": {"crystal": 50},
		"build_time": 10.0,
		"max_health": 75,
		"speed": 100,
		"damage": 10,
		"fire_rate": 0.66,
		"range": 32,
		"supply_cost": 1,
	}
}
