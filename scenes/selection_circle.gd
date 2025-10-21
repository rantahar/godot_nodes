# in selection_visuals.gd
extends Node2D

@export var ring_color: Color = Color(0.1, 0.8, 0.1, 0.5) # Semi-transparent green
@export var outer_radius: float = 20.0
@export var inner_radius: float = 15.0 # Creates the transparent middle
@export var visible_on_start: bool = true # Should be false by default

func _ready():
	# Make sure it starts hidden
	visible = visible_on_start
	queue_redraw()

# This function is called by Godot to draw custom elements
func _draw():
	# Draw the outer filled circle
	draw_circle(Vector2.ZERO, outer_radius, ring_color)
	
	# Draw a smaller, fully transparent circle in the middle
	# to create the "ring" effect. Or use a background color if appropriate.
	draw_circle(Vector2.ZERO, inner_radius, Color(0, 0, 0, 0)) # Fully transparent black


func set_visibility(is_visible: bool):
	visible = is_visible
	# If the visibility changes, we need to tell Godot to redraw
	# so the _draw() function is called.
	if is_visible:
		queue_redraw()
