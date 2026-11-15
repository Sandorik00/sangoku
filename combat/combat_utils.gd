extends Node
class_name CombatUtils

enum TARGETING_TARGETS { ALLY, ENEMY, ALL }

# Targeting and movement
enum TARGETING_TYPE { SOLO, SOLO_WITH_MOVE, AREA, AREA_FROM_ENTITY }

func enable_targeting(combat: Combat, skill: Skill):
	combat.targeting_setup()

	match skill.targeting_type:
		TARGETING_TYPE.SOLO:
			_solo_target(combat, combat.unit_entity, skill)

		_: return

func _solo_target(combat: Combat, unit_entity: SanGrid.GridEntity, skill: Skill):
	var grid = combat.grid

	var reachable_entitie_cells = grid.get_reachable_entity_cells(unit_entity.cell, skill.targeting_range)
	var blue_units: Array[SanGrid.GridCell] = reachable_entitie_cells.filter(func(cell: SanGrid.GridCell):
		return cell.entity.unitNode.team == Types.TEAMS.BLUE)
	var red_units: Array[SanGrid.GridCell] = reachable_entitie_cells.filter(func(cell: SanGrid.GridCell):
		return cell.entity.unitNode.team == Types.TEAMS.RED)

	var allies := blue_units if unit_entity.unitNode.team == Types.TEAMS.BLUE else red_units
	var enemies := red_units if unit_entity.unitNode.team == Types.TEAMS.BLUE else blue_units

	var allowed_targets = _match_targeting(skill, allies, enemies)

	combat.skill_active = skill
	combat.skill_allowed_targets = allowed_targets
	_draw_targets_overlay(combat, allowed_targets)

func _match_targeting(skill: Skill, allies: Array[SanGrid.GridCell], enemies: Array[SanGrid.GridCell]):
	match skill.targeting_targets:
		TARGETING_TARGETS.ALLY:
			return allies

		TARGETING_TARGETS.ENEMY:
			return enemies

		TARGETING_TARGETS.ALL:
			return allies + enemies

func _draw_targets_overlay(combat: Combat, targets: Array[SanGrid.GridCell]):
	var overlayTileMap = combat.overlayTileMap

	overlayTileMap.draw_targets_overlay(targets, combat.unit_entity)

# Effects
enum EFFECTS { DAMAGE, HEAL }

func apply_effect(combat: Combat, effect: EFFECTS, target_cells: Array[SanGrid.GridCell], skill: Skill) -> Array[SanGrid.GridEntity]:
	combat.end_targeting()

	match effect:
		EFFECTS.DAMAGE:
			return _damage_entities_on_cells(combat, target_cells, skill.power)

		EFFECTS.HEAL:
			return []

		_:
			return []
	
func _damage_entities_on_cells(combat: Combat, target_cells: Array[SanGrid.GridCell], power: int) -> Array[SanGrid.GridEntity]:
	var dead_units: Array[SanGrid.GridEntity] = []

	for cell in target_cells:
		var dead_unit = _damage_entity_on_cell(combat, cell, power)
		if dead_unit != null:
			dead_units.push_back(dead_unit)

	return dead_units

func _damage_entity_on_cell(combat: Combat, target_cell: SanGrid.GridCell, power: int) -> SanGrid.GridEntity:
	return combat.calculate_damage_for_entity(combat.unit_entity, target_cell.entity, power)
