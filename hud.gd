extends CanvasLayer

@onready var resource_label: Label = $Label

func set_player(player_node):
	# Connect this UI's update function to the player's signal.
	player_node.resources_updated.connect(update_resource_label)
	# Set the initial value.
	update_resource_label(player_node.resources)

func update_resource_label(new_amount: int):
	resource_label.text = "Resources: %s" % new_amount
