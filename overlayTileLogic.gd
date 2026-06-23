extends TileMapLayer
class_name OverlayTileMap

func drawWalkZone(moveList: Array[SanGrid.GridCell]):
	for node in moveList:
		if node.entity.type == SanGrid.GridEntityType.UNIT and node.entity.team == Types.TEAMS.BLUE:
			set_cell(node.xy, 0, Vector2(8, 8))
		else:
			node.isWalkTile = true
			set_cell(node.xy, 0, Vector2(6, 12))

func draw_reach_zone(cellList: Array[SanGrid.GridCell], unit_entity: SanGrid.GridEntity):
	for cell in cellList:
		if cell.entity.type == SanGrid.GridEntityType.UNIT and (unit_entity.enemies & cell.entity.team) != 0: 
			set_cell(cell.xy, 0, Vector2(3, 1))

		# set_cell(cell.xy, 0, Vector2(4, 1))
		
func clearWalkZone(grid: SanGrid, cells: Array[SanGrid.GridCell]):
	grid.clear_walk_tiles(cells)

func clearReachZone(grid: SanGrid, cells: Array[SanGrid.GridCell]):
	grid.clear_reach_tiles(cells)
