extends Node
class_name CombatState

signal turn_passed(unit: SanGrid.GridEntity)

# var _combatants: Array[SanGrid.GridEntity]
var _turn_order: Array[SanGrid.GridEntity]

var _current_unit: SanGrid.GridEntity

func add_combatants(combatants: Array[SanGrid.GridEntity]):
	if combatants.is_empty(): return

	for combatant in combatants:
		_turn_order.push_back(combatant)

	_current_unit = _turn_order[0]

	turn_passed.emit(_current_unit)
