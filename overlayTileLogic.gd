extends TileMapLayer
class_name OverlayTileMap

func drawWalkZone(moveList: Array[SanGrid.GridCell]):
	for node in moveList:
		node.isWalkTile = true
		set_cell(node.xy, 0, Vector2(6, 12))
		
func clearWalkZone(grid: SanGrid, cells: Array[SanGrid.GridCell]):
	grid.clear_walk_tiles(cells)
	clear()
