extends RefCounted
class_name WorldBTSelector

var actions: Array[WorldBTNode] = []

func _init(p_actions: Array[WorldBTNode]):
	actions = p_actions

func make_decision(faction: FactionData, context: Dictionary) -> void:
	var best_action: WorldBTNode = null
	var highest_score: float = -1.0
	
	for action in actions:
		var score = action.evaluate(faction, context)
		
		if score > highest_score:
			highest_score = score
			best_action = action
			
	if best_action != null and highest_score > 0.0:
		best_action.execute(faction, context)
