extends Node2D
class_name SanGrid

var grid: Array[GridCell]
var width: int = 0
var height: int = 0
var move_array: Array[GridCell] = []

var astar = AStarGrid2D.new()

enum GridEntityType { EMPTY, UNIT }

class GridEntity:
	var id: int
	var type: GridEntityType
	var unitNode: UnitEntity
	var cell: GridCell

	func _init(
		_type: GridEntityType = GridEntityType.EMPTY,
		_unitNode: Node2D = null,
	):
		self.type = _type
		self.unitNode = _unitNode

class GridCell:
	var entity: GridEntity
	var parent: GridCell = null
	var xy: Vector2i
	#TODO: bitmask walkability?
	var isWalkTile: bool = false
	var isInReach: bool = false
	
	func _init(_xy: Vector2i, _entity: GridEntity = GridEntity.new()):
		self.entity = _entity
		self.xy = _xy

class CostNode:
	var g_cost: int = -1
	var h_cost: int = -1
	var f_cost: int = -1

	func _init(g: int, h: int):
		self.g_cost = g
		self.h_cost = h
		self.f_cost = g + h

func create_grid(x: int, y: int):
	grid.resize(x * y)
	width = x
	height = y

	astar.region = Rect2i(0, 0, x, y)
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	for i in grid.size():
		grid[i] = GridCell.new(self.xy_for_index(i))
		# astar.set_point_solid(Vector2i(x, y), true)

func set_entity(x: int, y: int, ent: GridEntity):
	var cell = self.get_cell(x, y)
	ent.cell = cell
	cell.entity = ent

	if ent.type == GridEntityType.UNIT:
		astar.set_point_solid(Vector2i(x, y), true)
	else: astar.set_point_solid(Vector2i(x, y), false)

func get_entity(x: int, y: int) -> GridEntity:
	return grid[x + y * width].entity
	
func get_cell(x: int, y: int) -> GridCell:
	return grid[x + y * width]
	
func xy_for_index(index: int) -> Vector2i:
	var y = index / width
	var x = index % width
	return Vector2i(x, y)

func is_cell_valid(x: int, y: int):
	if x < 0 || x >= width: return false
	if y < 0 || y >= height: return false
	return true
	
func get_neighbours(xy: Vector2i) -> Array[GridCell]:
	var neighbours: Array[GridCell] = []
	var x = xy.x
	var y = xy.y

	const DIRS = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

	for dir in DIRS:
		var nx = x + dir.x
		var ny = y + dir.y
		if is_cell_valid(nx, ny):
			neighbours.append(grid[nx + ny * width])
	
	return neighbours

func _get_astar_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [
		cell + Vector2i.UP,
		cell + Vector2i.DOWN,
		cell + Vector2i.LEFT,
		cell + Vector2i.RIGHT
	]
	
func get_distance(cell_a: GridCell, cell_b: GridCell) -> int:
	var dst_x = abs(cell_a.xy.x - cell_b.xy.x)
	var dst_y = abs(cell_a.xy.y - cell_b.xy.y)
	
	return dst_x + dst_y
	
func clear_walk_tiles(cells: Array[GridCell]):
	for node in cells:
		node.parent = null
		node.isWalkTile = false

func clear_reach_tiles(cells: Array[GridCell]):
	for cell in cells:
		cell.isInReach = false

func calculateWalkZone(node: GridCell, mov: int) -> Array[GridCell]:
	var startNode = node

	var openSet: Array[GridCell] = []
	var openSetDict: Dictionary = {}
	var closedSet: Array[GridCell] = []
	var closedSetDict: Dictionary = {}

	var costMap: Dictionary = {}

	openSet.append(startNode)
	openSetDict[startNode] = true
	costMap[startNode] = 0

	while openSet.size() > 0:
		var currentNode: GridCell = openSet.pop_front()
		openSetDict.erase(currentNode)

		if closedSetDict.has(currentNode):
			continue

		closedSet.append(currentNode)
		closedSetDict[currentNode] = true

		var currentCost: int = costMap[currentNode]
		if currentCost >= mov:
			continue

		for neighbour in get_neighbours(currentNode.xy):
			if neighbour.entity.type != GridEntityType.EMPTY:
				continue
			if closedSetDict.has(neighbour):
				continue
			if openSetDict.has(neighbour):
				continue

			neighbour.parent = currentNode
			costMap[neighbour] = currentCost + 1

			openSet.append(neighbour)
			openSetDict[neighbour] = true

	return closedSet

func calculateWalkPath(destination: GridCell) -> Array[GridCell]:
	var path: Array[GridCell] = []
	var parent: GridCell = destination

	while parent != null:
		path.push_back(parent)
		parent = parent.parent

	path.reverse()

	return path

func get_reachable_cells(currCell: GridCell, reach: int) -> Array[GridCell]:
	var reachable_cells: Array[GridCell] = []

	var openSet: Array[GridCell] = []
	openSet.push_back(currCell)

	for i in range(reach):
		var tempSet: Array[GridCell] = openSet.duplicate()
		openSet.clear()

		for j in tempSet:
			var neighbours := (
				self.get_neighbours(j.xy)
				.filter(func(cell): return !cell.isInReach)
				.filter(func(cell): return cell != currCell) as Array[GridCell]
			)
			for n in neighbours:
				n.isInReach = true
			reachable_cells.append_array(neighbours)
			openSet.append_array(neighbours)
		
	return reachable_cells

func calculate_path_to_cell(start_cell: GridCell, target_cell: GridCell) -> Array[GridCell]:
	var start_coords = Vector2i(start_cell.xy.x, start_cell.xy.y)
	var target_coords = Vector2i(target_cell.xy.x, target_cell.xy.y)

	astar.set_point_solid(start_coords, false)

	var id_path: Array[Vector2i] = astar.get_id_path(start_coords, target_coords)
	
	if astar.is_point_solid(target_coords):
		var neighbors = _get_astar_neighbors(target_coords)
		var best_neighbor: Vector2i
		var min_distance = INF
		var found_valid_neighbor = false

		for neighbor in neighbors:
			if astar.is_in_bounds(neighbor.x, neighbor.y) and not astar.is_point_solid(neighbor):
				var manhattan_dist = abs(neighbor.x - start_coords.x) + abs(neighbor.y - start_coords.y)

				if manhattan_dist < min_distance:
					min_distance = manhattan_dist
					best_neighbor = neighbor
					found_valid_neighbor = true

		if found_valid_neighbor:
			id_path = astar.get_id_path(start_coords, best_neighbor)

	if id_path.is_empty():
		astar.set_point_solid(start_coords, true)
		return []

	var cell_path: Array[GridCell] = []
	for coords in id_path:
		var cell := get_cell(coords.x, coords.y)
		cell_path.append(cell)
		
	astar.set_point_solid(start_coords, true)
	return cell_path
