extends TileMapLayer
class_name OverlayTileMap

func drawWalkZone(moveList: Array[SanGrid.GridCell]):
	for node in moveList:
		node.isWalkTile = true
		set_cell(node.xy, 0, Vector2(6, 12))

func draw_reach_zone(cellList: Array[SanGrid.GridCell]):
	for cell in cellList:
		if cell.entity.type == SanGrid.GridEntityType.ENEMY: 
			set_cell(cell.xy, 0, Vector2(3, 1))

		# set_cell(cell.xy, 0, Vector2(4, 1))
		
func clearWalkZone(grid: SanGrid, cells: Array[SanGrid.GridCell]):
	grid.clear_walk_tiles(cells)

func clearReachZone(grid: SanGrid, cells: Array[SanGrid.GridCell]):
	grid.clear_reach_tiles(cells)
