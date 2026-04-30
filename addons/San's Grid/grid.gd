extends Node2D
class_name SanGrid

var grid: Array[GridCell]
var player_xy = Vector2i(0, 0) #Vector in tileset coords
var width: int = 0
var height: int = 0
var move_array: Array[GridCell] = []

enum GridEntityType { EMPTY, UNIT }

class GridEntity:
	var id: int
	var type: GridEntityType
	var unitNode: Node2D
	var cell: GridCell
	var friendly: bool

	func _init(_type: GridEntityType = GridEntityType.EMPTY, _unitNode: Node2D = null, _friendly: bool = false):
		self.type = _type
		self.unitNode = _unitNode
		self.friendly = _friendly

	func set_cell(cell: GridCell):
		var ent = self
		cell.entity = ent
		ent.cell = cell

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

	func set_entity(ent: GridEntity):
		var cell = self
		ent.cell = cell
		cell.entity = ent

func create_grid(x: int, y: int):
	grid.resize(x * y)
	width = x
	height = y
	for i in grid.size():
		grid[i] = GridCell.new(self.xy_for_index(i))

func set_entity(x: int, y: int, ent: GridEntity):
	var cell = self.get_cell(x, y)
	ent.cell = cell
	cell.entity = ent

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
	
func get_distance(node: GridCell) -> int:
	var currentNode := node
	var n = 1
	while currentNode.parent != null:
		n = n + 1
		currentNode = currentNode.parent
	
	return n
	
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
