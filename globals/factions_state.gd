extends Node

enum FACTIONS { SAN, RIK, ROMBUS, PARADOX }

var FACTIONS_TEXT: Dictionary[FACTIONS, String] = {
	FACTIONS.SAN: "San",
	FACTIONS.RIK: "Rik",
	FACTIONS.ROMBUS: "Rombus",
	FACTIONS.PARADOX: "Paradox",
}

var _relations: Dictionary = {}

func _get_key(f1: FACTIONS, f2: FACTIONS) -> String:
	var keys = [f1, f2]
	keys.sort()
	return "%s_%s" % [keys[0], keys[1]]

func set_relation(f1: FACTIONS, f2: FACTIONS, value: int) -> void:
	if f1 == f2: return
	_relations[_get_key(f1, f2)] = clampi(value, -100, 100)

func get_relation(f1: FACTIONS, f2: FACTIONS) -> int:
	if f1 == f2: return 100
	return _relations.get(_get_key(f1, f2), 0)

func _ready() -> void:
	set_relation(FACTIONS.SAN, FACTIONS.RIK, -24)
	set_relation(FACTIONS.SAN, FACTIONS.ROMBUS, -25)
	set_relation(FACTIONS.SAN, FACTIONS.PARADOX, 80)

	set_relation(FACTIONS.RIK, FACTIONS.ROMBUS, 100)
	set_relation(FACTIONS.RIK, FACTIONS.PARADOX, 0)

	set_relation(FACTIONS.ROMBUS, FACTIONS.PARADOX, -100)
