class_name Structure
extends StaticBody2D

@export var max_health: int = 30
@export var health: float = 1

var _armor: int = 0
var armor: int:
	get:
		return _armor
	set(value):
		var prev = _armor
		_armor = value
		if prev == 0 and value > 0:
			$ShieldEffect.visible = true
		elif prev > 0 and value == 0:
			$ShieldEffect.visible = false

var grid: Node = null
var slot
var expansion: ExpansionNode


@onready var selectionIndicator = $SelectionIndicator
@onready var maintenance_timer: Timer = $MaintenanceTimer
var progress_ability: Ability = null

@export var building_type = ""
@export var is_built = false
var stats: Dictionary
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
	
	apply_stats()
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
		enforce_ability_priority()

func execute_button_ability(ability_name: String, player: Player) -> bool:
	for child in get_children():
		if child is ButtonAbility and child.ability_name == ability_name and child.is_available():
			var result = child.execute(player)
			return result
	return false

func apply_stats():
	if not grid or not grid.controller:
		return
	var player = grid.controller
	stats = player.get_structure_stats(building_type)
	max_health = stats["max_health"]
	$HealthBar.max_value = max_health

func enforce_ability_priority():
	var abilities = get_abilities_in_order()
	
	var an_ability_is_blocking = false
	for ability in abilities:
		
		if an_ability_is_blocking:
			ability.disable()
		else:
			if not ability.is_active:
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


func modulate():
	if is_built:
		$Sprite2D.modulate.a = 1.0
	else:
		$Sprite2D.modulate.a = 0.5

func force_navmesh_sync():
	global_position.x += 0.001 

func finish_build() -> void:
	is_built = true
	enable_abilities()
	modulate()
	EventBus.emit_signal("structure_built", self)
	
	var nav_region = get_tree().get_first_node_in_group("nav_region")
	if is_instance_valid(nav_region):
		$NavigationObstacle2D.affect_navigation_mesh = true
		$NavigationObstacle2D.carve_navigation_mesh = true
		force_navmesh_sync()
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
	amount -= armor
	if amount > 0:
		health -= amount
	if health <= 0:
		destroy()

func heal(amount: float):
	health += amount
	if health > max_health:
		health = max_health
