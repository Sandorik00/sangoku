extends Node2D

@export_category("SanGrid")
@export var grid: SanGrid
@export var grid_dimensions: Vector2i

@export_category("TileMap")
@export var tileMap: TileMapLayer
@export var overlayTileMap: OverlayTileMap

@export_category("Units")
@export var unitPS: PackedScene

@export_category("Logic")
@export var combatState: CombatState

var unit_selected: SanGrid.GridEntity
var walkZone: Array[SanGrid.GridCell] = []
var walkPath: Array[SanGrid.GridCell] = []

func _ready():
	combatState.turn_passed.connect(_setup_unit_turn)

	grid.create_grid(grid_dimensions.x, grid_dimensions.y)
	for y in grid_dimensions.y:
		for x in grid_dimensions.x:
			tileMap.set_cell(Vector2(x, y), 0, Vector2(3, 1))

	# place unitPS
	var posForUnit = to_global(tileMap.map_to_local(Vector2(9, 5)))
	var u = unitPS.instantiate()
	u.position = posForUnit
	var uEntity = grid.GridEntity.new(grid.GridEntityType.UNIT, u)
	grid.set_entity(9, 5, uEntity)

	grid.add_child(u)

	combatState.add_combatants([uEntity])
	

func _setup_unit_turn(unit: SanGrid.GridEntity):
	walkZone = grid.calculateWalkZone(unit.cell, 6)
	overlayTileMap.drawWalkZone(walkZone)
	unit_selected = unit


func _unhandled_input(event: InputEvent):
	if unit_selected == null: return

	if event is InputEventMouseButton && event.button_index == 1 && !event.is_pressed():
		var correctedPosition = tileMap.get_global_mouse_position()
		var tile = tileMap.local_to_map(correctedPosition)
		print("Tiles: %s %s" % [tile.x, tile.y])
		print(grid.get_cell(tile.x, tile.y).xy)
		
		#Unit is not selected
		# if TurnLogic.unitIsSelected == null:
		# 	if MyGrid.get_entity(tile.x, tile.y) == MyGrid.GridEntity.PLAYER:
		# 		TurnLogic.unitIsSelected = MyGrid.get_cell(tile.x, tile.y)
		# 		drawMap(node, tile)
		# 		TurnLogic.nextActionPhase()

		var currCell = grid.get_cell(tile.x, tile.y)
		if currCell.isWalkTile == true:
			var cell = unit_selected.cell
			
			currCell.entity = cell.entity
			cell.entity = SanGrid.GridEntity.new()
			
			#unit_selected.unitNode.position = posForUnit

			walkPath = grid.calculateWalkPath(currCell)
			_tween_path()
		else:
			overlayTileMap.clearWalkZone(grid, walkZone)
			walkZone = []

func _tween_path():
	var unitNode2D = unit_selected.unitNode
	var tween = get_tree().create_tween()

	# var currentPos = unitNode2D.position
	# var prevDirection = Vector2i(0, 0)
	# for i in walkPath.size():
	# 	var cell = walkPath[i]
	# 	var easeIn = i == 0
	# 	var easeOut = true
	# 	if i < walkPath.size() - 1:
	# 		var nextCell = walkPath[i + 1]
	# 		var direction = nextCell.xy - cell.xy
	# 		easeOut = direction != prevDirection
	# 		prevDirection = direction

	# 	var nextPos = tileMap.to_global(tileMap.map_to_local(cell.xy))
	# 	var prop = tween.tween_property(unitNode2D, "position", nextPos, 1.0)

	# 	if easeIn and easeOut:
	# 		prop.set_ease(Tween.EASE_IN_OUT)
	# 		prop.set_trans(Tween.TRANS_CUBIC)
	# 	elif easeIn and not easeOut:
	# 		prop.set_trans(Tween.TRANS_CUBIC)
	# 		prop.set_ease(Tween.EASE_IN)
	# 	elif not easeIn and easeOut:
	# 		prop.set_trans(Tween.TRANS_CUBIC)
	# 		prop.set_ease(Tween.EASE_OUT)
	# 	else:
	# 		prop.set_trans(Tween.TRANS_LINEAR)

	# for i in walkPath.size():
	# 	var cell = walkPath[i]
	# 	var nextCell = walkPath.get(i + 1)

	# 	if nextCell != null:
	# 		pass

	var i = 0
	while i < walkPath.size():
		var segmentStart = i
		var cell = walkPath[i]
		i += 1

		if i < walkPath.size():
			var nextCell = walkPath[i]
			var segmentDirection = nextCell.xy - cell.xy

			while i < walkPath.size():
				nextCell = walkPath[i]
				var direction = nextCell.xy - cell.xy
				if direction != segmentDirection:
					break
				i += 1
				cell = nextCell

		var segmentLength = i - segmentStart
		var nextPos = tileMap.to_global(tileMap.map_to_local(cell.xy))
		tween.tween_property(unitNode2D, "position", nextPos, segmentLength * 0.5).set_trans(Tween.TRANS_CUBIC)

	tween.tween_callback(_clear_walk_zone)

func _clear_walk_zone():
	overlayTileMap.clearWalkZone(grid, walkZone)
	walkZone = []
