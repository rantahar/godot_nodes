extends Node

signal resources_generated(amount, grid)
signal unit_produced(unit_data)
signal upgrade_completed(upgrade_name: String, player: Player)
signal structure_built(structure: Structure)
signal score_generated(doctrine: String, amount: float, player: Player)
signal terraformer_registered(source: Terraformer, player: Player)
signal terraformer_unregistered(source: Terraformer)
