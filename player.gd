class_name Player
extends Node

signal resources_updated()

var factions: Array[Faction] = []

var resources: int:
	get:
		var total = 0
		if factions: # Check if the array is populated
			for faction in factions:
				total += faction.resources
		return total

func _on_resources_updated():
	emit_signal("resources_updated", resources)
