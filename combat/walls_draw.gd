extends Node2D
class_name WallsDraw

@export var tile_map: TileMapLayer
@export var wall_color: Color = Color.BLACK

var _cells: Array[Vector2i] = []

func set_cells(cells: Array[Vector2i]) -> void:
	_cells = cells
	queue_redraw()

func _draw() -> void:
	if tile_map == null or tile_map.tile_set == null: return

	var tile_size := Vector2(tile_map.tile_set.tile_size)

	for cell in _cells:
		var cell_center := tile_map.map_to_local(cell)
		draw_rect(Rect2(cell_center - tile_size / 2.0, tile_size), wall_color)
