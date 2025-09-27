class_name NetworkNode
extends Structure

signal resources_generated(amount)
var produce_resource = false


func check_for_crystal_proximity():
	var overlapping_areas: Array[Area2D] = $Area2D.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.get_parent().is_in_group("crystals"):
			produce_resource = true
			$Timer.start() 
			break

func _on_build_timer_timeout() -> void:
	super()
	check_for_crystal_proximity()

func _on_timer_timeout() -> void:
	if produce_resource:
		emit_signal("resources_generated", 5)
