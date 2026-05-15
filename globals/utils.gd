extends Node

func nextEnumMember(enumz: Dictionary, current: int):
	return wrapi(current + 1, 0, enumz.size() - 1)

func prevEnumMember(enumz: Dictionary, current: int):
	if current - 1 < 0:
		return 0
	return wrapi(current - 1, 0, enumz.size() - 1)

class TurnOrderArray extends RefCounted:
	var _data: Array[SanGrid.GridEntity]
	var _index: int = 0

	func _init(__data: Array[SanGrid.GridEntity] = []) -> void:
		_data = __data

	func _sort_initiative(a: SanGrid.GridEntity, b: SanGrid.GridEntity):
		var unit_data_a: Unit = CombatData.unitsInCombat[a.id]
		var unit_data_b: Unit = CombatData.unitsInCombat[b.id]

		return unit_data_a.initiative > unit_data_b.initiative

	func sort_by_initiative():
		_data.sort_custom(_sort_initiative)

	func get_array_copy():
		return _data.duplicate()

	func get_next() -> SanGrid.GridEntity:
		if _data.is_empty(): return null

		var result = _data[_index]
		_index = wrapi(_index + 1, 0, _data.size())

		return result

	func remove_unit(unit: SanGrid.GridEntity):
		_data.remove_at(_data.find(unit))
	