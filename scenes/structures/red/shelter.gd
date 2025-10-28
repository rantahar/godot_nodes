extends Structure

func apply_stats():
	var ability = $ShelterAbility
	ability.shelter_goal_time = stats.get("shelter_goal_time", ability.shelter_goal_time)
