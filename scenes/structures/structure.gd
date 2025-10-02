class_name Structure
extends StaticBody2D

@export var max_health: int = 30
@export var health: int = 30
@export var faction: Node = null
@export var maintenance_cost: int = 1

signal structure_selected(node)
signal structure_destroyed(structure)

@onready var selectionIndicator = $SelectionIndicator
@onready var maintenance_timer: Timer = $MaintenanceTimer
var connections: Array[Connection] = []

@export var is_built = false
var is_preview = false

func _ready():
	disable_abilities()
	modulate()

func disable_abilities():
	for child in get_children():
		if child is Ability:
			child.disable()

func enable_abilities():
	for child in get_children():
		if child is Ability and not child.is_active:
			child.enable()

func set_preview():
	is_preview = true
	$Area2D.collision_layer = 1 << 31

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("structure_selected", self)

func modulate():
	if is_preview:
		return
	if is_built:
		$Sprite2D.modulate.a = 1.0
	else:
		$Sprite2D.modulate.a = 0.5


func _on_build_timer_timeout() -> void:
	if is_preview:
		return
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
		return faction.charge_maintenance(cost)
	return true

func _on_maintenance_tick():
	var maintained = faction.charge_maintenance(maintenance_cost)
	if maintained:
		enable_abilities()
		repair(1)
	else:
		disable_abilities()
		take_damage(1)

func add_connection(connection: Connection):
	connections.append(connection)

func _on_destroyed():
	pass 

func right_click_command(location):
	pass

func repair(amount: int):
	if health < max_health:
		health += 1

func take_damage(amount: int):
	health -= amount
	print(self, health)
	if health <= 0:
		emit_signal("structure_destroyed", self)
		_on_destroyed()
		for connection in connections:
			if is_instance_valid(connection):
				connection.queue_free()
		queue_free()
