extends Resource
class_name Region

@export var id: int
@export var name: String
@export var castle_count: int = 1
@export var captured: Dictionary[FactionsState.FACTIONS, int] # Faction Id and number of reinforcements
@export var faction: FactionsState.FACTIONS
