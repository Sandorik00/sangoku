@abstract
extends RefCounted
class_name WorldBTNode

# float from 0.0 to 1.0+
# TODO: real types
@abstract func evaluate(_faction: FactionData, _context: Dictionary) -> float

@abstract func execute(_faction: FactionData, _context: Dictionary) -> void
