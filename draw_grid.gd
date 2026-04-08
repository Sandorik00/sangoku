# Скрипт на дочернем узле Node2D
extends Node2D

@export var grid_size = Vector2i(20, 20)
@export var cell_size = 32
@export var line_color = Color(1, 1, 1, 0.5)

func _draw():
    # Рисуем вертикальные линии
    for x in range(grid_size.x + 1):
        draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, grid_size.y * cell_size), line_color)
    
    # Рисуем горизонтальные линии
    for y in range(grid_size.y + 1):
        draw_line(Vector2(0, y * cell_size), Vector2(grid_size.x * cell_size, y * cell_size), line_color)
