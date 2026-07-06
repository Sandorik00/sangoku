extends Resource
class_name FactionData

@export var faction: FactionsState.FACTIONS

# resources
@export var money: int = 0

# dynamic stats basically
@export var army_power: int = 0

# not so dynamic stats
@export_range(0.0, 2.0, 0.1) var evilness: float = 1 # from 0 to 2 in extreme cases
