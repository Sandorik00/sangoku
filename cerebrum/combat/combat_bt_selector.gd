extends RefCounted
class_name CombatBTSelector

var actions: Array[CombatBTNode] = []

func _init(p_actions: Array[CombatBTNode]):
	actions = p_actions

func make_decision(unit: SanGrid.GridCell, grid: SanGrid, context: Dictionary) -> void:
	var best_action: CombatBTNode = null
	var highest_score: float = -1.0
	
	for action in actions:
		var score = action.evaluate(unit, grid, context)
		
		if score > highest_score:
			highest_score = score
			best_action = action
			
	if best_action != null and highest_score > 0.0:
		best_action.execute(unit, grid, context)
