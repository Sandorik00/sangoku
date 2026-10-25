extends Node2D
class_name Combat

# var UCS := UnitControlsState

var unit_id: int = 0
@onready var combat_ui: Control = $/root/Main/CanvasLayer/CombatUI
@onready var command_panel: CommandPanel = $/root/Main/CanvasLayer/CommandPanel
@onready var world: Node2D = $/root/Main/CanvasLayer/World
@onready var world_camera: Camera2D = $/root/Main/CanvasLayer/WorldCamera
@onready var global_ui: Control = $/root/Main/CanvasLayer/UI
@onready var preparation_panel: PreparationPanel = $/root/Main/CanvasLayer/PreparationPanel

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
@export var movement_range: int = 0

@export_category("Utils")
@export var camera: Camera2D
@export var speed := 100

var attackSpawnPositions: Array[Vector2] = [Vector2(1, 1), Vector2(2, 2), Vector2(1, 3), Vector2(13, 5)]
var defenceSpawnPositions: Array[Vector2] = [Vector2(15, 4), Vector2(14, 6), Vector2(15, 4)]
var additionalSpawnPositions: Array[Vector2] = [Vector2(8, 8)]

var unit_entity: SanGrid.GridEntity
var unit_active: Unit
var walkZone: Array[SanGrid.GridCell] = []
var walkPath: Array[SanGrid.GridCell] = []

var reachZone: Array[SanGrid.GridCell] = []

var transitionInProgress: bool = true :
	set(new_value):
		transitionInProgress = new_value
		command_panel.mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED\
			if new_value == true\
			else Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED

var combat_ended: bool = false 

var is_my_turn: bool = false
var is_player_attacker: bool = true
var is_preparations: bool = true

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var preparation_positions: Array[Vector2] = []

var player_entities: Dictionary[int, SanGrid.GridEntity] = {}
var enemy_entities: Dictionary[int, SanGrid.GridEntity] = {}
var combatants: Dictionary[int, SanGrid.GridEntity] = {}

var chosen_for_placement: SanGrid.GridEntity = null

var cerebrum: CombatBTSelector

## Call before adding to the scene
func setup_combat_entities(p_units: Array[Unit], e_units: Array[Unit], is_p_attacker: bool):
	player_units = p_units
	enemy_units = e_units

	is_player_attacker = is_p_attacker

func _process(delta):
	var movement := Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
		
	movement = speed * movement.normalized()
	camera.position += movement * delta
	camera.position = camera.position.clamp(Vector2(-20, -20), Vector2(20, 35))
	combat_ui.position = -camera.position * 6

func _ready():
	combatState.turn_passed.connect(_setup_unit_turn)
	combatState.end_combat.connect(_on_end_combat)
	# UCS.nextState.connect(_setup_new_state)
	command_panel.end_turn_button.connect("pressed", _on_end_turn_pressed)
	command_panel.mouse_behavior_recursive = Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED

	cerebrum = CombatBTSelector.new([
		CombatAttackAction.new(),
	])

	grid.create_grid(grid_dimensions.x, grid_dimensions.y)
	for y in grid_dimensions.y:
		for x in grid_dimensions.x:
			tileMap.set_cell(Vector2(x, y), 0, Vector2(3, 1))

	# place units
	_create_unit_entities(player_units, Types.TEAMS.BLUE, player_entities)
	_create_unit_entities(enemy_units, Types.TEAMS.RED, enemy_entities)

	var player_positions := attackSpawnPositions if is_player_attacker else defenceSpawnPositions
	var enemy_positions := attackSpawnPositions if not is_player_attacker else defenceSpawnPositions

	overlayTileMap.drawPreparationsCells(player_positions)
	preparation_positions = player_positions

	_fill_positions(player_entities.values(), player_positions)
	_fill_positions(enemy_entities.values(), enemy_positions)

	# setup preparations
	var unit_cards_map := preparation_panel.create_unit_cards(player_entities)
	for comb_id in combatants.keys():
		var card = unit_cards_map.get(comb_id)
		if not card: continue

		(card as PreparationUnitCard).dim()

	preparation_panel.unit_for_placement_changed.connect(_on_unit_for_placement_changed)
	preparation_panel.unit_remove.connect(_on_unit_remove_from_prep)

	preparation_panel.start_combat_btn.pressed.connect(_start_combat)

	preparation_panel.show()

func _create_unit_entities(units_for_creation: Array[Unit], team: Types.TEAMS, combatant_entities: Dictionary):
	for u in units_for_creation:
		var unitNode: UnitEntity = unitPS.instantiate() as UnitEntity
		unitNode.unit_data = u
		unitNode.prepare()
		unitNode.team = team

		var uEntity = grid.GridEntity.new(grid.GridEntityType.UNIT, unitNode)
		uEntity.id = unit_id

		combatant_entities.set(unit_id, uEntity)
		unit_id += 1

func _fill_positions(entities_for_placement: Array[SanGrid.GridEntity], positions_list: Array[Vector2]):
	for i in positions_list.size():
		if entities_for_placement.size() <= i: return

		var spawnPos = positions_list[i]
		var posForUnit = to_global(tileMap.map_to_local(spawnPos))

		var entity = entities_for_placement[i]

		entity.unitNode.position = posForUnit

		grid.set_entity(spawnPos.x, spawnPos.y, entity)
		grid.add_child(entity.unitNode)

		combatants.set(entity.id, entity)

func _on_unit_for_placement_changed(id: int):
	chosen_for_placement = player_entities.get(id)

func _on_unit_remove_from_prep(id: int):
	var combatant: SanGrid.GridEntity = combatants.get(id)
	if !combatant || !combatant.unitNode: return

	combatants.erase(combatant.id)
	grid.remove_child(combatant.unitNode)
	grid.set_entity(combatant.cell.xy.x, combatant.cell.xy.y, SanGrid.GridEntity.new())

func _start_combat():
	overlayTileMap.clear()
	var combatants_mapping: Dictionary[int, Unit] = {}

	for c: SanGrid.GridEntity in combatants.values():
		combatants_mapping.set(c.id, c.unitNode.unit_data)

	CombatData.unitsInCombat = combatants_mapping
	CombatData.add_units_ui(combatants.values())
	combatState.add_combatants(combatants.values())

	preparation_panel.hide()
	is_preparations = false
	
func _setup_unit_turn(unit: SanGrid.GridEntity):
	if unit.unitNode.team != Types.TEAMS.BLUE:
		unit_entity = unit
		unit_entity = unit
		unit_active = CombatData.unitsInCombat[unit.id]
		CombatData.panel_unit_data = unit_active
		CombatData.move_unit_label(unit)

		var enemy_cells: Array = combatState\
			.get_list_of_player_entities()\
			.map(func(ent: SanGrid.GridEntity): return ent.cell)
		
		await cerebrum.make_decision(unit, grid, { "combat": self, "enemy_cells": enemy_cells })

		await get_tree().create_timer(0.5).timeout

		combatState.pass_turn()
		return

	unit_entity = unit
	unit_active = CombatData.unitsInCombat[unit.id]
	CombatData.panel_unit_data = unit_active
	movement_range = unit_active.movement
	CombatData.move_unit_label(unit)
	_calc_and_draw_zone(unit_active.movement)

func _calc_and_draw_zone(mov: int):
	walkZone = grid.calculateWalkZone(unit_entity.cell, mov)
	overlayTileMap.drawWalkZone(walkZone)
	_calc_and_draw_reach(unit_active.attack_range)

func _calc_and_draw_reach(reach: int):
	reachZone = grid.get_reachable_cells(unit_entity.cell, reach)
	overlayTileMap.draw_reach_zone(reachZone, unit_entity)
	transitionInProgress = false

func _unhandled_input(event: InputEvent):
	# PREPARATIONS
	if is_preparations:
		if event is InputEventMouseButton && event.button_index == 1 && !event.is_pressed():
			var correctedPosition = tileMap.get_global_mouse_position()
			var tile = tileMap.local_to_map(correctedPosition)

			if preparation_positions.has(tile):
				# bad UX, need to rechoose unit
				if chosen_for_placement == null: return

				# remove old unit from cell if present
				var old_entity = grid.get_entity(tile.x, tile.y)
				if old_entity.unitNode:
					combatants.erase(old_entity.id)
					grid.remove_child(old_entity.unitNode)

				# add new unit to cell
				var posForUnit = to_global(tileMap.map_to_local(tile))

				var reuse_combatant: SanGrid.GridEntity = combatants.get(chosen_for_placement.id)
				chosen_for_placement.unitNode.position = posForUnit

				if reuse_combatant:
					grid.set_entity(reuse_combatant.cell.xy.x, reuse_combatant.cell.xy.y, SanGrid.GridEntity.new())
					grid.set_entity(tile.x, tile.y, reuse_combatant)
				else:
					grid.set_entity(tile.x, tile.y, chosen_for_placement)
					grid.add_child(chosen_for_placement.unitNode)
					combatants.set(chosen_for_placement.id, chosen_for_placement)

				preparation_panel.unit_was_placed.emit(old_entity.id)
		
		return

	# CONTROLS
	if unit_entity == null or transitionInProgress: return

	if event is InputEventMouseButton && event.button_index == 1 && !event.is_pressed():
		var correctedPosition = tileMap.get_global_mouse_position()
		var tile = tileMap.local_to_map(correctedPosition)

		var currCell = grid.get_cell(tile.x, tile.y)

		# Walk and Attack and whatsoever
		if currCell.isWalkTile == true:
			move_player(currCell)
		elif currCell.isInReach and (unit_entity.unitNode.enemies & currCell.entity.unitNode.team) != 0:
			unit_basic_attack(currCell)

func move_player(destination: SanGrid.GridCell):
	transitionInProgress = true
	var cell = unit_entity.cell
	
	grid.set_entity(destination.xy.x, destination.xy.y, cell.entity)
	grid.set_entity(cell.xy.x, cell.xy.y, SanGrid.GridEntity.new())
	
	walkPath = grid.calculateWalkPath(destination)
	_tween_path()

func move_npc(destination_path: Array[SanGrid.GridCell]):
	if destination_path.is_empty(): return

	var entity = unit_entity
	var unit_movement = min(destination_path.size(), unit_entity.unitNode.unit_data.movement)

	var actual_destination_path: Array[SanGrid.GridCell] = destination_path.slice(0, unit_movement)
	var actual_destination: SanGrid.GridCell = actual_destination_path.get(actual_destination_path.size() - 1)
	
	grid.set_entity(entity.cell.xy.x, entity.cell.xy.y, SanGrid.GridEntity.new())
	grid.set_entity(actual_destination.xy.x, actual_destination.xy.y, entity)

	walkPath = actual_destination_path
	await _tween_path()

func unit_basic_attack(enemy_cell: SanGrid.GridCell):
	transitionInProgress = true

	var dead_unit := _calculate_attack(unit_entity, enemy_cell.entity)
	CombatData.update_labels_for_units([unit_entity, enemy_cell.entity])

	if dead_unit: _on_unit_death(dead_unit)
	if combat_ended: return

	_clear_walk_zone()
	combatState.pass_turn()

func npc_basic_attack(enemy_cell: SanGrid.GridCell):
	var dead_unit := _calculate_attack(unit_entity, enemy_cell.entity)
	CombatData.update_labels_for_units([unit_entity, enemy_cell.entity])

	if dead_unit: _on_unit_death(dead_unit)

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

		# Calculatons for troops label
		var next_label_pos = ((nextPos * 6) + (Vector2(-16, 8) * 3))

		tween.tween_property(unitNode2D, "position", nextPos, segmentLength * 0.5).set_trans(Tween.TRANS_QUINT)
		tween.parallel().tween_property(CombatData.moving_label, "position", next_label_pos, segmentLength * 0.5).set_trans(Tween.TRANS_QUINT)

	if unit_entity.unitNode.team == Types.TEAMS.BLUE:
		tween.tween_callback(_cycle_walk_zone)
	else: await tween.finished

func _cycle_walk_zone():
	var last_pass_lenght = max(walkPath.size() - 1, 0)

	_clear_walk_zone()

	movement_range -= last_pass_lenght
	_calc_and_draw_zone(movement_range)

func _clear_walk_zone():
	overlayTileMap.clearWalkZone(grid, walkZone)
	overlayTileMap.clearReachZone(grid, reachZone)
	overlayTileMap.clear()
	walkZone = []
	walkPath = []
	reachZone = []

func _calculate_attack(attacker_e: SanGrid.GridEntity, defender_e: SanGrid.GridEntity) -> SanGrid.GridEntity:
	var dead_unit: SanGrid.GridEntity = null

	var attacker = attacker_e.unitNode.unit_data
	var defender = defender_e.unitNode.unit_data

	var a_true_attack: int = attacker.attack - defender.defence
	var a_true_damage: int = max((attacker.troops * a_true_attack) * 0.3, 1)

	var d_true_attack: int = defender.attack - attacker.defence
	var d_true_damage: int = max((defender.troops * d_true_attack) * 0.1, 1)

	defender.troops = max(defender.troops - a_true_damage, 0)
	if defender.troops == 0:
		d_true_damage = min(d_true_damage, attacker.troops - 1)
		dead_unit = defender_e

	attacker.troops = max(attacker.troops - d_true_damage, 0)
	if attacker.troops == 0:
		dead_unit = attacker_e

	return dead_unit

func _on_unit_death(unit: SanGrid.GridEntity):
	combat_ended = combatState.on_unit_death(unit)
	var node_for_deletion = unit.unitNode
	node_for_deletion.queue_free()
	CombatData.unitsInCombat.erase(unit.id)
	grid.set_entity(unit.cell.xy.x, unit.cell.xy.y, SanGrid.GridEntity.new())

func _on_end_turn_pressed():
	transitionInProgress = true

	_clear_walk_zone()

	combatState.pass_turn()

func _on_end_combat(attacker_is_winner: bool):
	WorldTurnLogic.out_combat(attacker_is_winner)
