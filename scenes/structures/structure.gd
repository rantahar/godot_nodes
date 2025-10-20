class_name Structure
extends StaticBody2D

@export var max_health: int = 30
@export var health: float = 1

var grid: Node = null
var slot
var expansion: ExpansionNode

signal structure_selected(node)

@onready var selectionIndicator = $SelectionIndicator
@onready var maintenance_timer: Timer = $MaintenanceTimer
var progress_ability: Ability = null

@export var building_type = ""
@export var is_built = false
var is_active = true
var build_progress: float = 0.0
var build_time: float = 100.0
var size = 16

func _ready():
	var gamedata = GameData
	var structure_data = gamedata.buildable_structures[building_type]
	build_time = structure_data["build_time"]
	max_health = structure_data["max_health"]
	progress_ability = find_progress_ability()
	disable_abilities()
	
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	var shape_size = $CollisionShape2D.shape.get_rect().size
	$HealthBar.position.y = -shape_size.y/2-8
	$HealthBar.position.x = -shape_size.x/2 - 4
	$HealthBar.scale.x = (shape_size.x + 8) / 96
	$ProgressBar.position.y = -shape_size.y/2-16
	$ProgressBar.position.x = -shape_size.x/2 - 4
	$ProgressBar.scale.x = (shape_size.x + 8) / 96
	$ProgressBar.max_value = 100
	modulate()

func _process(delta):
	$HealthBar.value = health
	progress_ability = find_progress_ability()
	if is_instance_valid(progress_ability):
		var progress = progress_ability.get_progress()
		if progress.in_progress:
			$ProgressBar.visible = true
			$ProgressBar.value = progress.current
		else:
			$ProgressBar.visible = false
	
	if is_built:
		enforce_ability_priority(delta)

func enforce_ability_priority(delta):
	var abilities = get_abilities_in_order()
	
	var an_ability_is_blocking = false
	for ability in abilities:
		if an_ability_is_blocking:
			ability.disable()
		else:
			ability.enable()
			if ability.is_executing():
				an_ability_is_blocking = true

func find_progress_ability() -> Ability:
	var abilities = get_abilities_in_order()
	for ability in abilities:
		if ability.is_executing():
			return ability
	return null

func disable_abilities():
	is_active = false
	$DisabledSprite.visible = true
	for child in get_children():
		if child is Ability:
			child.disable()

func enable_abilities():
	var main = expansion.main_building
	if is_instance_valid(main) and main.grid == grid:
		is_active = true
		$DisabledSprite.visible = false
		for child in get_children():
			if child is Ability and not child.is_active:
				child.enable()

func toggle_abilities():
	if is_active:
		disable_abilities()
	else:
		enable_abilities()


func get_abilities_in_order() -> Array[Ability]:
	var result: Array[Ability] = []
	for child in get_children():
		if child is Ability:
			result.append(child)
	return result

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("structure_selected", self)

func modulate():
	if is_built:
		$Sprite2D.modulate.a = 1.0
	else:
		$Sprite2D.modulate.a = 0.5

func force_navmesh_syn():
	global_position.x += 0.001 

func finish_build() -> void:
	is_built = true
	enable_abilities()
	modulate()
	
	var nav_region = get_tree().get_first_node_in_group("nav_region")
	if is_instance_valid(nav_region):
		$NavigationObstacle2D.affect_navigation_mesh = true
		$NavigationObstacle2D.carve_navigation_mesh = true
		force_navmesh_syn()
		nav_region.refresh()

func charge_ability_cost(cost) -> bool:
	return grid.charge_maintenance(cost)

func right_click_command(location):
	pass

func destroy():
	slot.is_free = true
	expansion.remove_structure(self)
	queue_free()

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		destroy()

func heal(amount: float):
	health += amount
	if health > max_health:
		health = max_health
