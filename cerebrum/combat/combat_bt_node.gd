@abstract
extends RefCounted
class_name CombatBTNode

signal completed

# float from 0.0 to 1.0+
# TODO: real types
@abstract func evaluate(_unit: SanGrid.GridEntity, _grid: SanGrid, _context: Dictionary) -> float

@abstract func execute(_unit: SanGrid.GridEntity, _grid: SanGrid, _context: Dictionary) -> void
