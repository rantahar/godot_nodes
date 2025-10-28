extends Structure

var shield_amount = 5

func _ready():
	super()
	shield_amount = stats["armor_value"]

func finish_build():
	super()
	for structure in expansion.structures:
		if structure.grid == grid:
			structure.armor = shield_amount

func destroy():
	var has_other_shield = false
	if is_built:
		for s in expansion.structures:
			if s != self and s.building_type == "shield" and s.is_built and s.grid == grid:
				has_other_shield = true
				break
		if not has_other_shield:
			for structure in expansion.structures:
				if structure.grid == grid:
					structure.armor = 0
			
	super()
