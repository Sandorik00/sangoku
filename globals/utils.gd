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
	
class UnitsStateDictionary extends RefCounted:
	var _data: Dictionary[int, Resource]
	var _last_index: int = 0
	var _free_buffer: Array[int] = []

	func _init(__data: Dictionary[int, Resource] = {}) -> void:
		_data = __data
		_last_index = __data.keys().size()

	func get_by_key(id: int) -> Resource:
		return _data.get(id)

	func set_batch(ress: Array[Resource]):
		for res in ress:
			self.set_last(res)

	func set_last(res: Resource):
		var curr_index: int = _last_index
		if not _free_buffer.is_empty():
			curr_index = _free_buffer.pop_back()
		else: _last_index += 1

		_data.set(curr_index, res)

		if res is Army or res is Commander:
			res.id = curr_index
		
	func erase_at(index: int):
		if index == -1: return

		_data.erase(index)
		_free_buffer.push_back(index)

	func keys() -> Array[int]:
		return _data.keys()
