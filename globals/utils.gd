extends Node

func nextEnumMember(enumz: Dictionary, current: int):
	return wrapi(current + 1, 0, enumz.size() - 1)

func prevEnumMember(enumz: Dictionary, current: int):
	if current - 1 < 0:
		return 0
	return wrapi(current - 1, 0, enumz.size() - 1)

class TurnOrderArray extends RefCounted:
	var _data: Array[SanGrid.GridEntity]
	var _index: int = -1

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

		_index = wrapi(_index + 1, 0, _data.size())
		var result = _data[_index]

		return result

	func remove_unit(unit: SanGrid.GridEntity):
		var unit_index = _data.find(unit)
		_data.remove_at(unit_index)
		
		if unit_index < _index:
			_index = wrapi(_index - 1, 0, _data.size())
		elif unit_index == _index:
			_index = wrapi(_index, 0, _data.size())

	
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

func get_actions_for_relation(relation: int):
	if relation > Types.FACTION_RELATIONS_MAP.ALLY:
		return Types.ACTIONS_FOR_RELATIONS.get(Types.FACTION_RELATIONS_MAP.ALLY)
	elif relation > Types.FACTION_RELATIONS_MAP.FRIENDLY:
		return Types.ACTIONS_FOR_RELATIONS.get(Types.FACTION_RELATIONS_MAP.FRIENDLY)
	elif relation > Types.FACTION_RELATIONS_MAP.WARY:
		return Types.ACTIONS_FOR_RELATIONS.get(Types.FACTION_RELATIONS_MAP.WARY)
	else:
		return Types.ACTIONS_FOR_RELATIONS.get(Types.FACTION_RELATIONS_MAP.ENEMY)

func get_actions_for_property(region: Region, faction: FactionsState.FACTIONS):
	var property_type: Types.REGION_PROPERTY_TYPE = Types.REGION_PROPERTY_TYPE.NONE
	if region.province.faction == faction:
		property_type = Types.REGION_PROPERTY_TYPE.CASTLE
	elif region.faction == faction:
		property_type = Types.REGION_PROPERTY_TYPE.REINFORCEMENTS

	return Types.ACTIONS_FOR_PROPERTY.get(property_type, [])

func collect_resources(dir_path: String) -> Array[String]:
	var file_paths: Array[String] = []

	var dir = DirAccess.open(dir_path)

	dir.list_dir_begin()

	var full_name = dir.get_next()

	while full_name != "":
		var path = dir_path.trim_suffix("/") + "/" + full_name

		if dir.current_is_dir():
			continue

		file_paths.append(path)
		full_name = dir.get_next()
	
	dir.list_dir_end()
	
	return file_paths
