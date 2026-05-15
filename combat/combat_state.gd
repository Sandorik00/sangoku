extends Node
class_name CombatState

signal turn_passed(unit: SanGrid.GridEntity)

@onready var _turn_order_ui: TurnOrder = $/root/Main/CanvasLayer/TurnOrder

var _turn_order: Utils.TurnOrderArray

var _current_unit: SanGrid.GridEntity

func add_combatants(combatants: Array[SanGrid.GridEntity]):
	if combatants.is_empty(): return

	_turn_order = Utils.TurnOrderArray.new(combatants.duplicate())
	_turn_order.sort_by_initiative()

	_current_unit = _turn_order.get_next()

	_turn_order_ui.add_units(_turn_order.get_array_copy(), _current_unit)

	turn_passed.emit(_current_unit)

func on_unit_death(unit: SanGrid.GridEntity):
	_turn_order.remove_unit(unit)
	_turn_order_ui.remove_unit(unit.id)

func pass_turn():
	_current_unit = _turn_order.get_next()
	_turn_order_ui.highlight_unit(_current_unit.id)

	turn_passed.emit(_current_unit)
