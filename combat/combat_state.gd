extends Node
class_name CombatState

signal turn_passed(unit: SanGrid.GridEntity)

# var _combatants: Array[SanGrid.GridEntity]
var _turn_order: Array[SanGrid.GridEntity]

var _current_unit: SanGrid.GridEntity

func add_combatants(combatants: Array[SanGrid.GridEntity]):
	if combatants.is_empty(): return

	_turn_order = combatants.duplicate()
	_turn_order.sort_custom(sort_initiative)

	_current_unit = _turn_order[0]

	turn_passed.emit(_current_unit)

func sort_initiative(a: SanGrid.GridEntity, b: SanGrid.GridEntity):
	var unit_data_a: Unit = CombatData.unitsInCombat[a.id]
	var unit_data_b: Unit = CombatData.unitsInCombat[b.id]

	return unit_data_a.initiative > unit_data_b.initiative
