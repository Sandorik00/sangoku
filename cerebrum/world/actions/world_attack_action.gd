extends WorldBTNode
class_name WorldAttackAction

func evaluate(faction: FactionData, _context: Dictionary) -> float:
	# var army_strength_ratio = faction.army_power / max(1.0, context.weakest_neighbor_power)
	# var base_score = clamp(army_strength_ratio - 0.5, 0.0, 1.5)

	var base_score = clamp(0.5, 0.0, 1.5)
	
	var final_score = base_score * faction.evilness
	
	# money matters?
	# if faction.money < 100:
	# 	final_score *= 0.2
		
	return final_score

func execute(faction: FactionData, _context: Dictionary) -> void:
	# TODO: proper faction and context usage
	print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " is attacking...")
	# WorldTurnLogic.into_combat()
