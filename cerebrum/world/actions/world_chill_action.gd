extends WorldBTNode
class_name WorldChillAction

func evaluate(faction: FactionData, _context: Dictionary) -> float:
	var base_score = clamp(0.5, 0.0, 1.5)
	var final_score = base_score / faction.evilness
		
	return final_score

func execute(faction: FactionData, _context: Dictionary) -> void:
	print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " is chilling...")
