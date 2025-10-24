class_name Terraformer
extends Structure

var grid_position: Vector2i

func finish_build():
	super()
	if is_instance_valid(grid) and is_instance_valid(grid.controller):
		EventBus.emit_signal("terraformer_registered", self, grid.controller)
	else:
		print("ERROR: Terraformer built without a valid grid or controller.")

func destroy():
	EventBus.emit_signal("terraformer_unregistered", self)
	super()
