extends Node
class_name CombatUtils

enum TARGETING_TARGETS { ALLY, ENEMY, ALL, TILE }

# Targeting and movement
enum TARGETING_TYPE { SOLO, SOLO_WITH_MOVE, AREA, AREA_FROM_ENTITY }

func enable_targeting(combat: Combat, skill: Skill):
	combat.targeting_setup()

	match skill.targeting_type:
		TARGETING_TYPE.SOLO:
			_solo_target(combat, combat.unit_entity, skill)

		TARGETING_TYPE.AREA:
			_area_target(combat, combat.unit_entity, skill)

		_: return

func _solo_target(combat: Combat, unit_entity: SanGrid.GridEntity, skill: Skill):
	var grid = combat.grid

	var reachable_entity_cells = grid.get_reachable_entity_cells(unit_entity.cell, skill.targeting_range)
	var blue_units: Array[SanGrid.GridCell] = reachable_entity_cells.filter(func(cell: SanGrid.GridCell):
		return cell.entity.unitNode.team == Types.TEAMS.BLUE)
	var red_units: Array[SanGrid.GridCell] = reachable_entity_cells.filter(func(cell: SanGrid.GridCell):
		return cell.entity.unitNode.team == Types.TEAMS.RED)

	var allies := blue_units if unit_entity.unitNode.team == Types.TEAMS.BLUE else red_units
	var enemies := red_units if unit_entity.unitNode.team == Types.TEAMS.BLUE else blue_units

	var allowed_targets = _match_solo_targeting(skill, allies, enemies)

	combat.skill_active = skill
	combat.skill_allowed_targets = allowed_targets
	_draw_targets_overlay(combat, allowed_targets)

func _match_solo_targeting(skill: Skill, allies: Array[SanGrid.GridCell], enemies: Array[SanGrid.GridCell]):
	match skill.targeting_targets:
		TARGETING_TARGETS.ALLY:
			return allies

		TARGETING_TARGETS.ENEMY:
			return enemies

		TARGETING_TARGETS.ALL:
			return allies + enemies

		_: return enemies

func _area_target(combat: Combat, unit_entity: SanGrid.GridEntity, skill: Skill):
	var grid = combat.grid

	var reachable_cells := grid.get_reachable_target_cells(unit_entity.cell, skill.targeting_range)

	var allowed_targets = _match_area_targeting(skill, reachable_cells)

	combat.skill_active = skill
	combat.skill_allowed_targets = allowed_targets
	_draw_targets_area_overlay(combat, allowed_targets)

func _match_area_targeting(skill: Skill, cells: Array[SanGrid.GridCell]):
	match skill.targeting_targets:
		TARGETING_TARGETS.ALLY:
			return cells.filter(func(cell: SanGrid.GridCell):
				return (cell.entity.unitNode != null and cell.entity.unitNode.team == Types.TEAMS.BLUE)
			)

		TARGETING_TARGETS.ENEMY:
			return cells.filter(func(cell: SanGrid.GridCell):
				return (cell.entity.unitNode != null and cell.entity.unitNode.team == Types.TEAMS.RED)
			)

		TARGETING_TARGETS.ALL:
			return cells.filter(func(cell: SanGrid.GridCell):
				return (cell.entity.unitNode != null and cell.entity.type == SanGrid.GridEntityType.UNIT)
			)

		TARGETING_TARGETS.TILE:
			return cells

		_: return cells


func _draw_targets_overlay(combat: Combat, targets: Array[SanGrid.GridCell]):
	var overlayTileMap = combat.overlayTileMap

	overlayTileMap.draw_targets_overlay(targets, combat.unit_entity)

func _draw_targets_area_overlay(combat: Combat, targets: Array[SanGrid.GridCell]):
	var overlayTileMap = combat.overlayTileMap

	overlayTileMap.draw_target_area_overlay(targets)

# Effects
enum EFFECTS { DAMAGE, HEAL }

func apply_effect(combat: Combat, effect: EFFECTS, target_cells: Array[SanGrid.GridCell], skill: Skill) -> Array[SanGrid.GridEntity]:
	combat.end_targeting()

	match effect:
		EFFECTS.DAMAGE:
			return _damage_entities_on_cells(combat, target_cells, skill)

		EFFECTS.HEAL:
			return []

		_:
			return []
	
func _damage_entities_on_cells(combat: Combat, target_cells: Array[SanGrid.GridCell], skill: Skill) -> Array[SanGrid.GridEntity]:
	var dead_units: Array[SanGrid.GridEntity] = []

	for cell in target_cells:
		var dead_unit = _damage_entity_on_cell(combat, cell, skill.power)
		if dead_unit != null:
			dead_units.push_back(dead_unit)

	return dead_units

func _damage_entity_on_cell(combat: Combat, target_cell: SanGrid.GridCell, power: int) -> SanGrid.GridEntity:
	return combat.calculate_damage_for_entity(combat.unit_entity, target_cell.entity, power)
