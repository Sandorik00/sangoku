extends Node

var all_units_data: Array[Unit] = []
var units_for_hire: Dictionary[FactionsState.FACTIONS, Dictionary] = {}

func _ready() -> void:
	var paths := Utils.collect_resources_recursive("res://units/factions")
	for path in paths:
		var res: Unit = ResourceLoader.load(path, "Unit")

		all_units_data.push_back(res)

func get_units_for_faction(faction: FactionsState.FACTIONS) -> Dictionary:
	var has_faction: bool = false
	var units_dict: Dictionary = units_for_hire.get(faction, {})

	if units_for_hire.has(faction): has_faction = true
	else: has_faction = false

	if not has_faction:
		if all_units_data.is_empty(): return {}

		for i in 3:
			if all_units_data.is_empty(): break

			var random_index := Grng.RNG.randi() % all_units_data.size()
			units_dict.set(i, all_units_data.pop_at(random_index))

		units_for_hire.set(faction, units_dict)
	
	return units_dict

func hire_unit(faction: FactionsState.FACTIONS, index: int) -> bool:
	var units_dict: Dictionary = units_for_hire.get(faction, {})
	if units_dict.is_empty(): return false

	var faction_data: FactionData = WorldState.FACTIONS_TO_DATA.get(faction)

	var unit: Unit = units_dict.get(index)
	var cost: int = unit.troops * 1

	if faction_data.money >= cost:
		faction_data.money -= cost
		faction_data.units.set_last(unit)
		units_dict.erase(index)
		units_for_hire.set(faction, units_dict)

		return true
	else: return false
