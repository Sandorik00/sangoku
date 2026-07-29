extends Resource
class_name Region

@export var id: int = -1
@export var name: String
@export var rank: int = 1
@export var faction: FactionsState.FACTIONS

var province: Province
