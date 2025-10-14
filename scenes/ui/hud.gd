extends CanvasLayer

signal build_button_clicked(type)
signal production_toggle_clicked()

@onready var crystal_label: Label = $ResourcePanel/Gray
@onready var green_crystal_label: Label = $ResourcePanel/Green
@onready var red_crystal_label: Label = $ResourcePanel/Red
@onready var blue_crystal_label: Label = $ResourcePanel/Blue
@onready var selection_panel: Panel = $SelectionPanel
@onready var ability_button_container: GridContainer = $SelectionPanel/GridContainer
var player: Player = null

func _on_selection_changed(selected_objects: Array):
	for child in ability_button_container.get_children():
		child.queue_free()
	
	if selected_objects.is_empty():
		selection_panel.visible = false
		return
	
	selection_panel.visible = true
	
	if selected_objects.size() == 1:
		var selection = selected_objects[0]
		if selection is ExpansionNode:
			if not player.can_claim_expansion(selection):
				return
		
		for child in selection.get_children():
			if child is Ability and child.has_button:
				var new_button = Button.new()
				new_button.text = child.action_name
				new_button.icon = child.action_icon
				new_button.pressed.connect(child.execute)
				ability_button_container.add_child(new_button)

func set_player(player_node):
	player = player_node
	player_node.resources_updated.connect(update_resource_label)
	update_resource_label(player_node.resources)

func update_resource_label(new_amount):
	crystal_label.text = "Crystals: %s" % new_amount["crystal"]
	green_crystal_label.text = "Crystals: %s" % new_amount["green_crystal"]
	red_crystal_label.text = "Crystals: %s" % new_amount["red_crystal"]
	blue_crystal_label.text = "Crystals: %s" % new_amount["blue_crystal"]

func _on_production_toggle_pressed() -> void:
	emit_signal("production_toggle_clicked")
