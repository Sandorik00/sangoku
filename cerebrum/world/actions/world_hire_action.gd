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

	var faction_available_units: Array[Army] = []

	for r: Region in WorldState.ALL_REGIONS.values():
		if r.faction == faction.faction:
			var unit_data: Array[Army] = HireLogic.all_units_data.get(r.id)
			faction_available_units.append_array(unit_data)

	if faction_available_units.is_empty(): return

	var currently_hiring: Army = faction_available_units.get(0)
	var cost: int = currently_hiring.base_cost * currently_hiring.number_of_troops

	if faction.money >= cost:
		faction.money -= cost
		faction.armies.set_last(currently_hiring)
		# HireLogic.update_regions_data(region_armies_after_hire)
		print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " hired: " + currently_hiring.name)
		faction.hired_this_week = true
	else: print("This is a bug!!")
