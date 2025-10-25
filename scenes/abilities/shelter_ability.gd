extends Ability

# When goal time is reached, marks the expansion as complete for the player

var shelter_goal_time: float = 120.0
var progress : float = 0.0
var done : bool = false

func _process(delta):
	progress += delta
	if progress >= shelter_goal_time:
		progress = shelter_goal_time

		var expansion = parent.expansion
		parent.grid.player.shelters.append(expansion)
		done = true

func is_executing():
	return not done

func get_progress() -> Dictionary:
	if done:
		return {
			"current": 100,
			"in_progress": false
		}

	var part_done = 100 * progress / shelter_goal_time
	return {
		"current": part_done,
		"in_progress": true
	}
