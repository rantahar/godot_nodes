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
var current_selection: Array = []


func _ready():
	EventBus.upgrade_completed.connect(_on_upgrade_completed)
	EventBus.structure_built.connect(_on_structure_built)

func refresh_buttons():
	for child in ability_button_container.get_children():
		child.queue_free()
	
	if current_selection.is_empty():
		selection_panel.visible = false
		return
	
	selection_panel.visible = true
	
	if current_selection.size() == 1:
		var selection = current_selection[0]
		if selection is ExpansionNode:
			if not player.can_claim_expansion(selection):
				return
		
		for child in selection.get_children():
			if child is ButtonAbility:
				if not child.is_available():
					continue
				var new_button = Button.new()
				new_button.text = child.button_text
				new_button.icon = child.button_icon
				new_button.pressed.connect(child.execute.bind(player))
				ability_button_container.add_child(new_button)

func _on_selection_changed(selected_objects: Array):
	current_selection = selected_objects
	refresh_buttons()

func _on_upgrade_completed(upgrade_name: String, upgraded_player: Player):
	if upgraded_player == player:
		refresh_buttons()

func _on_structure_built(structure: Structure):
	if structure.grid.controller == player:
		refresh_buttons()

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
