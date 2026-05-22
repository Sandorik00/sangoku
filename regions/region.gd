extends Resource
class_name Region

@export var id: int
@export var name: String
@export var castle_count: int = 1
@export var captured: Dictionary[FactionsState.FACTIONS, int] # Faction Id and Castle Id
@export var faction: FactionsState.FACTIONS
