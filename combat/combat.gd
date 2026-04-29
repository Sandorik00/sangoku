extends Node2D

var UCS := UnitControlsState

var unit_id: int = 0

@export_category("SanGrid")
@export var grid: SanGrid
@export var grid_dimensions: Vector2i

@export_category("TileMap")
@export var tileMap: TileMapLayer
@export var overlayTileMap: OverlayTileMap

@export_category("Units")
@export var unitPS: PackedScene
@export var armyResource: Army
@export var commanderResource: Commander

@export var enemyArmyResource: Army
@export var enemyCommanderResource: Commander

@export_category("Logic")
@export var combatState: CombatState
@export var movement_range: int = 6

@export_category("Utils")
@export var camera: Camera2D
@export var speed := 100

var unitsInCombat: Dictionary[int, Unit] = {}
var spawnPositions: Array[Vector2] = [Vector2(9, 5), Vector2(13, 7)]

var unit_entity: SanGrid.GridEntity
var unit_active: Unit
var walkZone: Array[SanGrid.GridCell] = []
var walkPath: Array[SanGrid.GridCell] = []

var reachZone: Array[SanGrid.GridCell] = []

var transitionInProgress: bool = true

## Call before adding to the scene
func setup_combat_entities(units: Array[Unit]):
	for u in units:
		unitsInCombat.set(unit_id, u)
		unit_id += 1

func _process(delta):
	var movement := Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
		
	movement = speed * movement.normalized()
	camera.position += movement * delta
	camera.position = camera.position.clamp(Vector2(-20, -20), Vector2(20, 35))

func _ready():
	# test code, delete later
	var ce: Array[Unit] = [Unit.new(), Unit.new()]

	for i in range(ce.size()):
		if (i + 1) % 2 == 0:
			var ue = ce[i]
			ue.army = enemyArmyResource
			ue.commander = enemyCommanderResource
			ue.team = Types.TEAMS.RED
			ue.calculate()
		else:
			var ue = ce[i]
			ue.army = armyResource
			ue.commander = commanderResource
			ue.team = Types.TEAMS.BLUE
			ue.calculate()

	self.setup_combat_entities(ce)

	########################################
	combatState.turn_passed.connect(_setup_unit_turn)
	UCS.nextState.connect(_setup_new_state)

	grid.create_grid(grid_dimensions.x, grid_dimensions.y)
	for y in grid_dimensions.y:
		for x in grid_dimensions.x:
			tileMap.set_cell(Vector2(x, y), 0, Vector2(3, 1))

	var combatants: Array[SanGrid.GridEntity] = []

	# place units
	for i in unitsInCombat.keys():
		var spawnPos = spawnPositions[i]
		var posForUnit = to_global(tileMap.map_to_local(spawnPos))

		var u = unitPS.instantiate() as UnitEntity
		u.unit_data = unitsInCombat[i]
		u.prepare()
		u.position = posForUnit

		var uEntity = grid.GridEntity.new(grid.GridEntityType.UNIT, u)
		uEntity.id = i

		grid.set_entity(spawnPos.x, spawnPos.y, uEntity)
		grid.add_child(u)

		combatants.push_back(uEntity)

	combatState.add_combatants(combatants)
	
func _setup_unit_turn(unit: SanGrid.GridEntity):
	unit_entity = unit
	unit_active = unitsInCombat[unit.id]
	UIState.panel_unit_data = unit_active
	_calc_and_draw_zone(unit_active.movement)

func _calc_and_draw_zone(mov: int):
	walkZone = grid.calculateWalkZone(unit_entity.cell, mov)
	overlayTileMap.drawWalkZone(walkZone)
	_calc_and_draw_reach(unit_active.attack_range)

func _calc_and_draw_reach(reach: int):
	reachZone = grid.get_reachable_cells(unit_entity.cell, reach)
	overlayTileMap.draw_reach_zone(reachZone)
	transitionInProgress = false

func _unhandled_input(event: InputEvent):
	if unit_entity == null or transitionInProgress: return

	if event is InputEventMouseButton && event.button_index == 1 && !event.is_pressed():
		var correctedPosition = tileMap.get_global_mouse_position()
		var tile = tileMap.local_to_map(correctedPosition)
		print("Tiles: %s %s" % [tile.x, tile.y])
		print(grid.get_cell(tile.x, tile.y).xy)

		var currCell = grid.get_cell(tile.x, tile.y)

		# Walk and Attack and whatsoever
		if UCS.current_state == UCS.UnitState.TURN:
			if currCell.isWalkTile == true:
				transitionInProgress = true
				var cell = unit_entity.cell
				
				currCell.set_entity(cell.entity)
				cell.set_entity(SanGrid.GridEntity.new())
				
				#unit_entity.unitNode.position = posForUnit

				walkPath = grid.calculateWalkPath(currCell)
				_tween_path()

		# End
		if UCS.current_state == UCS.UnitState.END:
			pass

			


func _tween_path():
	var unitNode2D = unit_entity.unitNode
	var tween = get_tree().create_tween()

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
		tween.tween_property(unitNode2D, "position", nextPos, segmentLength * 0.5).set_trans(Tween.TRANS_QUINT)

	tween.tween_callback(_clear_walk_zone)

func _clear_walk_zone():
	var last_pass_lenght = walkPath.size() - 1

	overlayTileMap.clearWalkZone(grid, walkZone)
	overlayTileMap.clearReachZone(grid, reachZone)
	overlayTileMap.clear()
	walkZone = []
	walkPath = []
	reachZone = []

	movement_range -= last_pass_lenght
	_calc_and_draw_zone(movement_range)
	# UnitControlsState.forward()

func _setup_new_state(state: UnitControlsState.UnitState):
	if state == UCS.UnitState.END:
		pass
