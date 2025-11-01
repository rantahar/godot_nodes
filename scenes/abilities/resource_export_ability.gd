extends Ability

var export_time: float = 5.0
var export_amount: int = 50
var progress : float = 0.0

func _process(delta):
	progress += delta
	if progress >= export_time:
		progress -= export_time
	
	var grid = parent.grid
	
	grid.spend_resources({"crystal": export_amount})
