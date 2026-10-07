extends CombatBTNode
class_name CombatAttackAction

func evaluate(_unit: SanGrid.GridEntity, _grid: SanGrid, _context: Dictionary) -> float:
	return 1.0

func execute(unit: SanGrid.GridEntity, grid: SanGrid, context: Dictionary) -> void:
	var enemy_cells: Array = context.get("enemy_cells")
	var combat: Combat = context.get("combat")

	var shortest_path: Array[SanGrid.GridCell] = []

	for enemy in enemy_cells:
		var new_path := grid.calculate_path_to_cell(unit.cell, enemy)
		if shortest_path.is_empty() || shortest_path.size() > new_path.size():
			shortest_path = new_path

	if not shortest_path.is_empty():
		await combat.move_npc(shortest_path)

	var reachable_enemy_cells: Array[SanGrid.GridCell] = grid.get_neighbours(unit.cell.xy)\
		.filter(func(n: SanGrid.GridCell): return n.entity.unitNode != null)\
		.filter(func(n: SanGrid.GridCell): return (unit.unitNode.enemies & n.entity.unitNode.team) != 0)

	if not reachable_enemy_cells.is_empty():
		var neighbor_cell_with_enemy: SanGrid.GridCell = reachable_enemy_cells.get(0)
		# print("fighters: ")
		# print(unit.unitNode.unit_data.name)
		# print(neighbor_cell_with_enemy.entity.unitNode.unit_data.name, "\n")

		combat.npc_basic_attack(neighbor_cell_with_enemy)

	completed.emit()
