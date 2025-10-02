extends CanvasLayer

signal build_button_clicked(type)
signal production_toggle_clicked()

@onready var resource_label: Label = $Label

func set_player(player_node):
	player_node.resources_updated.connect(update_resource_label)
	update_resource_label(player_node.resources)

func update_resource_label(new_amount: int):
	resource_label.text = "Resources: %s" % new_amount

func _on_production_toggle_pressed() -> void:
	emit_signal("production_toggle_clicked")

func _on_node_button_pressed() -> void:
	emit_signal("build_button_clicked", "network_node")

func _on_cannon_button_pressed() -> void:
	emit_signal("build_button_clicked", "cannon")

func _on_mine_button_pressed() -> void:
	emit_signal("build_button_clicked", "mine")

func _on_factory_button_pressed() -> void:
	emit_signal("build_button_clicked", "factory")
