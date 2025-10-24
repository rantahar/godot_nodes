class_name TerraCell
extends RefCounted

var owner: Player = null
var oxygen: float = 0.0
var source_amount: float = 0.0

func _init(p_owner: Player, p_oxygen: float, source_amount: float = 0.0):
	self.owner = p_owner
	self.oxygen = p_oxygen
	self.source_amount = source_amount
