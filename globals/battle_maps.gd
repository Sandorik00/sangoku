extends Node

const MAP_SIZE: Vector2i = Vector2i(20, 12)

const WALL_X_MIN: int = 11
const WALL_X_MAX: int = 12
const GATE_Y_MIN: int = 1
const GATE_Y_MAX: int = 10

## { region_id: Array[Vector2i] }
var _walls_by_region: Dictionary[int, Array] = {}

func _ready() -> void:
	# WorldState normally fills ALL_REGIONS before this autoload is ready,
	# the deferred call is just a safety net for autoload order changes.
	if WorldState.ALL_REGIONS.is_empty():
		call_deferred("generate_all")
	else:
		generate_all()

func generate_all() -> void:
	_walls_by_region.clear()

	for region_id in WorldState.ALL_REGIONS.keys():
		_walls_by_region.set(region_id, _generate_walls())

func get_walls(region_id: int) -> Array[Vector2i]:
	if not _walls_by_region.has(region_id):
		_walls_by_region.set(region_id, _generate_walls())

	var walls: Array[Vector2i] = []
	walls.assign(_walls_by_region.get(region_id))
	return walls

func _generate_walls() -> Array[Vector2i]:
	var rng: RandomNumberGenerator = Grng.RNG
	var walls: Dictionary[Vector2i, bool] = {}

	var wall_x: int = rng.randi_range(WALL_X_MIN, WALL_X_MAX)
	var gates: Array[int] = _pick_gates(rng)

	for y in MAP_SIZE.y:
		if gates.has(y): continue
		_put_wall(walls, Vector2i(wall_x, y))

	for y in MAP_SIZE.y:
		if gates.has(y): continue
		if rng.randf() < 0.5:
			_put_wall(walls, Vector2i(wall_x - 1, y))

	for y in MAP_SIZE.y:
		if gates.has(y): continue
		if rng.randf() < 0.55:
			var length: int = rng.randi_range(1, 2)
			for i in length:
				_put_wall(walls, Vector2i(wall_x - 2 - i, y))

	for y in [0, MAP_SIZE.y - 1]:
		if gates.has(y): continue
		_put_wall(walls, Vector2i(wall_x - 1, y))

	var result: Array[Vector2i] = []
	result.assign(walls.keys())
	result.sort_custom(_sort_walls)
	return result

func _sort_walls(a: Vector2i, b: Vector2i) -> bool:
	return a.y < b.y or (a.y == b.y and a.x < b.x)

func _pick_gates(rng: RandomNumberGenerator) -> Array[int]:
	var gates: Array[int] = []
	var gate_count: int = rng.randi_range(1, 2)

	while gates.size() < gate_count:
		var gate_y: int = rng.randi_range(GATE_Y_MIN, GATE_Y_MAX)
		if not gates.has(gate_y):
			gates.append(gate_y)

	return gates

func _put_wall(walls: Dictionary[Vector2i, bool], cell: Vector2i) -> void:
	if cell.x < 0 or cell.x >= MAP_SIZE.x: return
	if cell.y < 0 or cell.y >= MAP_SIZE.y: return

	walls.set(cell, true)
