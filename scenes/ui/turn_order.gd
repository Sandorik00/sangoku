extends Control
class_name TurnOrder

@export var turn_order_unit: PackedScene
@export var units_container: HBoxContainer

var units_by_id: Dictionary[int, TurnOrderUnit] = {}
var last_highlighted: int = -1

func add_units(units: Array[SanGrid.GridEntity], first: SanGrid.GridEntity):
	for unit in units:
		var unit_inst: TurnOrderUnit = turn_order_unit.instantiate()
		units_by_id.set(unit.id, unit_inst)
		units_container.add_child(unit_inst)

		if unit == first:
			unit_inst.highlight()
			last_highlighted = unit.id

func highlight_unit(unit_id: int):
	var last_highlighted_unit = units_by_id.get(last_highlighted)
	if last_highlighted_unit:
		(last_highlighted_unit as TurnOrderUnit).blur()
	(units_by_id.get(unit_id) as TurnOrderUnit).highlight()
	last_highlighted = unit_id

func remove_unit(unit_id: int):
	var unit_node = units_by_id.get(unit_id) as TurnOrderUnit
	units_by_id.erase(unit_id)
	unit_node.queue_free()

func clear_turn_order():
	for u in units_by_id.values():
		u.queue_free()

	units_by_id.clear()
	last_highlighted = -1
