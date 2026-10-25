extends Resource
class_name UnitsStateDictionary

@export var _data: Dictionary[int, Unit] = {}
@export var _last_index: int = 0
@export var _free_buffer: Array[int] = []

func _init(__data: Dictionary[int, Unit] = {}) -> void:
	_data = __data
	_last_index = __data.keys().size()

func get_by_key(id: int) -> Unit:
	return _data.get(id)

func set_batch(ress: Array[Unit]):
	for res in ress:
		self.set_last(res)

func set_last(res: Unit):
	var curr_index: int = _last_index
	if not _free_buffer.is_empty():
		curr_index = _free_buffer.pop_back()
	else: _last_index += 1

	_data.set(curr_index, res)

	res.id = curr_index
	
func erase_at(index: int):
	if index == -1: return

	_data.erase(index)
	_free_buffer.push_back(index)

func keys() -> Array[int]:
	return _data.keys()

func values() -> Array[Unit]:
	return _data.values()

func size() -> int:
	return _data.size()

func is_empty() -> bool:
	return _data.is_empty()

func get_army_power() -> int:
	var array: Array[Unit] = self.values()
	var power = array.reduce(func(acc, unit: Unit): return acc + (unit.troops * unit.level), 0)

	return power

func get_all_sorted_by_lvl_asc() -> Array[Unit]:
	var array: Array[Unit] = self.values()
	array.sort_custom(func(a: Unit, b: Unit): return a.level < b.level)

	return array

func get_least_troops(count: int) -> Array[Unit]:
	var array: Array[Unit] = self.values()
	array = array.filter(func(u: Unit): return u.troops != u.max_troops)
	array.sort_custom(func(a: Unit, b: Unit): return a.troops < b.troops)
	array = array.slice(0, count)

	return array
