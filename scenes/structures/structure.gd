class_name Structure
extends StaticBody2D

@export var max_health: int = 30
@export var health: int = 30
@export var maintenance_cost: int = 1

var grid: Node = null
var expansion: ExpansionNode

signal structure_selected(node)
signal structure_destroyed(structure)

@onready var selectionIndicator = $SelectionIndicator
@onready var maintenance_timer: Timer = $MaintenanceTimer

@export var is_built = false
var is_active = true

func _ready():
	disable_abilities()
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	var shape_size = $CollisionShape2D.shape.get_rect().size
	$HealthBar.position.y = -shape_size.y/2-8
	$HealthBar.position.x = -shape_size.x/2 - 4
	$HealthBar.scale.x = (shape_size.x + 8) / 96
	modulate()

func disable_abilities():
	for child in get_children():
		if child is Ability:
			child.disable()

func enable_abilities():
	for child in get_children():
		if child is Ability and not child.is_active:
			child.enable()

func toggle_abilities():
	if is_active:
		is_active = false
		$DisabledSprite.visible = true
		disable_abilities()
	else:
		is_active = true
		$DisabledSprite.visible = false
		enable_abilities()
	

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("structure_selected", self)

func modulate():
	if is_built:
		$Sprite2D.modulate.a = 1.0
	else:
		$Sprite2D.modulate.a = 0.5


func _on_build_timer_timeout() -> void:
	is_built = true
	modulate()
	enable_abilities()
	
	var nav_region = get_tree().get_first_node_in_group("nav_region")
	if is_instance_valid(nav_region):
		$NavigationObstacle2D.affect_navigation_mesh = true
		$NavigationObstacle2D.carve_navigation_mesh = true
		nav_region.bake_navigation_polygon()
	
	if maintenance_timer:
		maintenance_timer.timeout.connect(_on_maintenance_tick)
		maintenance_timer.start()

func charge_ability_cost(cost) -> bool:
	if cost > 0:
		return grid.charge_maintenance(cost)
	return true

func _on_maintenance_tick():
	var maintained = grid.charge_maintenance(maintenance_cost)
	if maintained:
		repair(1)
	else:
		take_damage(1)

func right_click_command(location):
	pass

func repair(amount: int):
	if health < max_health:
		health += 1

func take_damage(amount: int):
	health -= amount
	$HealthBar.value = health
	if health <= 0:
		emit_signal("structure_destroyed", self)
		queue_free()
