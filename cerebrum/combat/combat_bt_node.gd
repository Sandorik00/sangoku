@abstract
extends RefCounted
class_name CombatBTNode

# float from 0.0 to 1.0+
# TODO: real types
@abstract func evaluate(_unit: SanGrid.GridCell, _grid: SanGrid, _context: Dictionary) -> float

@abstract func execute(_unit: SanGrid.GridCell, _grid: SanGrid, _context: Dictionary) -> void
