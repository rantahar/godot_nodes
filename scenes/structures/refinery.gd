class_name Refinery
extends Structure


func _on_build_timer_timeout():
	super()
	$RefineAbility.enable()
