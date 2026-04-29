extends Node

signal chosen_region_changed(region: Region)

# combat ui signals
signal unit_data_changed(unit: Unit)

var chosen_region: Region :
	set(new_value):
		chosen_region = new_value
		chosen_region_changed.emit(new_value)

var forces_pressed: bool = false

### Combat ui
var panel_unit_data: Unit :
	set(new_value):
		panel_unit_data = new_value
		unit_data_changed.emit(new_value)
