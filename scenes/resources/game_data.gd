extends Node


var abilities = {
	"refine": {
		"resource_amount": 2,
		"resource_cost": {"crystal": 2},
		"refine_time": 1,
	},
	"export": {
		"export_amount": 50,
		"export_time": 5.0,
	},
	"shelter": {
		"shelter_goal_time": 120.0,
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
	# build structures, only prerequisites here
	"build_main_building": {
		"structure_type": "main_building",
		"button_text": "Network Node",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_mine": {
		"structure_type": "mine",
		"button_text": "Mine",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_cannon": {
		"structure_type": "cannon",
		"button_text": "Cannon",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_factory": {
		"prerequisites": {
			"upgrade": "main_building_level_2"
		},
		"structure_type": "factory",
		"button_text": "Factory",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_red_refinery": {
		"structure_type": "red_refinery",
		"button_text": "Red Refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_shelter": {
		"prerequisites": {
			"structure": "red_refinery"
		},
		"structure_type": "shelter",
		"button_text": "Shelter",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_blue_refinery": {
		"structure_type": "blue_refinery",
		"button_text": "Blue Refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_space_port": {
		"prerequisites": {
			"structure": "blue_refinery"
		},
		"structure_type": "space_port",
		"button_text": "Space Port",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_green_refinery": {
		"structure_type": "green_refinery",
		"button_text": "Green Refinery",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	},
	"build_terraformer": {
		"prerequisites": {
			"structure": "green_refinery"
		},
		"structure_type": "terraformer",
		"button_text": "Terraformer",
		"icon": preload("res://assets/kenney_ui-pack/PNG/Blue/Default/button_round_flat.png"),
	}
}

var buildable_structures = {
	"main_building": {
		"name": "network_node",
		"scene": "res://scenes/structures/main_building.tscn",
		"cost": {"crystal": 300},
		"build_time": 30.0,
		"max_health": 1500,
		"location": "main"
	},
	"mine": {
		"name": "mine",
		"scene": "res://scenes/structures/mine.tscn",
		"cost": {"crystal": 10},
		"build_time": 1.0,
		"generation_rate": 2,
		"max_health": 150,
		"location": "crystal"
	},
	"cannon": {
		"name": "cannon",
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
		"scene": "res://scenes/structures/factory.tscn",
		"cost": {"crystal": 150},
		"build_time": 15.0,
		"max_health": 800,
		"supply": 4,
		"location": "building_slot"
	},
	"red_refinery": {
		"name": "red refinery",
		"scene": "res://scenes/structures/redrefinery.tscn",
		"cost": {"crystal": 200},
		"build_time": 15.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"shelter": {
		"name": "shelter",
		"scene": "res://scenes/structures/shelter.tscn",
		"cost": {"crystal": 150},
		"build_time": 10.0,
		"max_health": 700,
		"location": "building_slot"
	},
	"blue_refinery": {
		"name": "blue refinery",
		"scene": "res://scenes/structures/bluerefinery.tscn",
		"cost": {"crystal": 200},
		"build_time": 1.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"space_port": {
		"name": "space port",
		"scene": "res://scenes/structures/space_port.tscn",
		"cost": {"crystal": 300, "blue_crystal": 20},
		"build_time": 20.0,
		"max_health": 800,
		"location": "building_slot"
	},
	"green_refinery": {
		"name": "green refinery",
		"scene": "res://scenes/structures/greenrefinery.tscn",
		"cost": {"crystal": 20},
		"build_time": 1.0,
		"max_health": 600,
		"location": "building_slot"
	},
	"terraformer": {
		"name": "Terraformer",
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
