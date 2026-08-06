extends Node

func refill_troops(faction_data: FactionData, unit: Unit, new_troops: int):
	if new_troops > unit.max_troops: print("This is a bug!")

	var troops_diff: int = unit.troops - new_troops

	faction_data.money += troops_diff * 1
	unit.troops = new_troops
