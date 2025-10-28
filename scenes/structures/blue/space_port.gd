extends Structure

func _apply_stats():
	var ability = $ResourceExportAbility
	ability.export_time = stats.get("export_time", ability.export_time)
	ability.export_amount = stats.get("export_amount", ability.export_amount)
