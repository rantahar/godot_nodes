class_name TerraCell
extends RefCounted

var owner: Player = null
var oxygen: float = 0.0
var potential: Dictionary = {}
var pos: Vector2i

func _init(p_owner: Player, p_oxygen: float, pos: Vector2i):
	self.owner = p_owner
	self.oxygen = p_oxygen
	self.pos = pos
	
