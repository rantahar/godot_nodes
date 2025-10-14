class_name MainBuilding
extends Structure

func destroy():
	grid.expansions.erase(expansion)
	super()
