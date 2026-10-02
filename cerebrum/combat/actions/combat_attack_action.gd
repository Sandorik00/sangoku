extends CombatBTNode
class_name CombatAttackAction

func evaluate(_unit: SanGrid.GridCell, _grid: SanGrid, _context: Dictionary) -> float:
	return 1.0

func execute(unit: SanGrid.GridCell, grid: SanGrid, context: Dictionary) -> void:
	var enemy_cells: Array = context.get("enemy_cells")
	var combat: Combat = context.get("combat")

	var paths_to_enemies: Array[Array] = []

	for enemy in enemy_cells:
		paths_to_enemies.push_back(grid.calculate_path_to_cell(unit, enemy))

	if paths_to_enemies.is_empty(): return

	paths_to_enemies.sort_custom(func(a: Array, b: Array): return a.size() < b.size())
	var shortest_path: Array[SanGrid.GridCell] = paths_to_enemies.get(0)

	combat.move_npc(shortest_path)
