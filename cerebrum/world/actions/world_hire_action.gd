extends WorldBTNode
class_name WorldHireAction

func evaluate(faction: FactionData, _context: Dictionary) -> float:
	var base_score = clamp(0.8, 0.0, 1.5)
	
	var final_score = base_score / faction.evilness
	
	if faction.money < 1000:
		final_score *= 0.1
	elif faction.money > 9999:
		final_score *= 1.2

	if faction.hired_this_week:
		final_score = 0
	
	return final_score

func execute(faction: FactionData, _context: Dictionary) -> void:
	print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " is hiring...")

	var faction_available_units: Dictionary = HireLogic.get_units_for_faction(faction.faction)

	if faction_available_units.is_empty(): return

	var hiring_end: bool = false
	var current_index: int = 0

	while not hiring_end:
		var currently_hiring_index = faction_available_units.keys().get(current_index)
		var currently_hiring: Unit = faction_available_units.get(currently_hiring_index)

		if HireLogic.hire_unit(faction.faction, currently_hiring_index):
			hiring_end = true
			faction.hired_this_week = true
			print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " hired: " + currently_hiring.name)

		current_index += 1
		if current_index >= faction_available_units.keys().size(): hiring_end = true
