extends Resource
class_name Region

@export var name: String
@export var castle_count: int = 1
@export var captured: Dictionary[int, int] # Faction Id and Castle Id
@export var faction: int
