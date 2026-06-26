extends Node

signal turn_end()

var _campaing_factions: Array[FactionsState.FACTIONS] = [] 

func _ready():
	turn_end.connect(_on_turn_end)

func _on_turn_end():
	pass
