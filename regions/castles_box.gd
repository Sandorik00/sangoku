extends Panel

@export var castleHBox: HBoxContainer
@export var castleIconPS: PackedScene

func add_castles(count: int):
	for i in range(count):
		castleHBox.add_child(castleIconPS.instantiate())
