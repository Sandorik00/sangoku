extends Node
class_name CombatState

signal turn_passed(unit: SanGrid.GridEntity)
signal end_combat(is_win: bool)

@onready var _turn_order_ui: TurnOrder = $/root/Main/CanvasLayer/TurnOrder

var _turn_order: Utils.TurnOrderArray
var _player_units: Dictionary[int, SanGrid.GridEntity]
var _enemy_units: Dictionary[int, SanGrid.GridEntity]

var _current_unit: SanGrid.GridEntity

func add_combatants(combatants: Array[SanGrid.GridEntity]):
	if combatants.is_empty(): return

	for c in combatants:
		if c.team == Types.TEAMS.BLUE: _player_units.set(c.id, c)
		elif c.team == Types.TEAMS.RED: _enemy_units.set(c.id, c)

	_turn_order = Utils.TurnOrderArray.new(combatants.duplicate())
	_turn_order.sort_by_initiative()

	_current_unit = _turn_order.get_next()

	_turn_order_ui.add_units(_turn_order.get_array_copy(), _current_unit)
	_turn_order_ui.show()

	turn_passed.emit(_current_unit)

func on_unit_death(unit: SanGrid.GridEntity):
	_turn_order.remove_unit(unit)
	_turn_order_ui.remove_unit(unit.id)

	if unit.team == Types.TEAMS.BLUE: _player_units.erase(unit.id)
	elif unit.team == Types.TEAMS.RED: _enemy_units.erase(unit.id)

	print(_player_units.keys())
	print(_enemy_units.keys())

	if _player_units.is_empty():
		_turn_order_ui.clear_turn_order()
		_turn_order_ui.hide()
		end_combat.emit(false)
		return
	elif _enemy_units.is_empty():
		_turn_order_ui.clear_turn_order()
		_turn_order_ui.hide()
		end_combat.emit(true)
		return

	self.pass_turn()

func pass_turn():
	_current_unit = _turn_order.get_next()
	_turn_order_ui.highlight_unit(_current_unit.id)

	turn_passed.emit(_current_unit)
