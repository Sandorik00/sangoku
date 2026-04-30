extends Node

signal unit_data_changed(unit: Unit)

var panel_unit_data: Unit :
	set(new_value):
		panel_unit_data = new_value
		unit_data_changed.emit(new_value)

var unitsInCombat: Dictionary[int, Unit] = {}
