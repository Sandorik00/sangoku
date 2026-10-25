extends WorldBTNode
class_name WorldRefillAction

func evaluate(faction: FactionData, _context: Dictionary) -> float:
	var base_score = clamp(1, 0.0, 1.5)
	
	var final_score = base_score / faction.evilness

	var for_reffil = faction.units.get_least_troops(3)
	if for_reffil.is_empty():
		final_score = 0
	else:
		var test_unit = for_reffil.get(0)
		if test_unit.troops < (test_unit.max_troops * 0.75):
			final_score *= 1.1
		else:
			final_score *= 0.5
	
	if faction.money < 100:
		final_score *= 0.2
	
	return final_score

func execute(faction: FactionData, _context: Dictionary) -> void:
	print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " is refilling...")

	var for_refill := faction.units.get_least_troops(3)
	var cost := 1

	for u in for_refill:
		var can_buy := faction.money / cost
		var buying = clamp(can_buy + u.troops, u.troops, u.max_troops)

		WorldActions.refill_troops(faction, u, buying)

	faction.recalculate_army_power()
