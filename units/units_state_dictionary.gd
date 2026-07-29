extends Resource
class_name UnitsStateDictionary

@export var _data: Dictionary[int, Resource] = {}
@export var _last_index: int = 0
@export var _free_buffer: Array[int] = []

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
