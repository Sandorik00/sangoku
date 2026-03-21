extends Node

signal chosen_region_changed(region: Region)

var chosen_region: Region :
	set(new_value):
		chosen_region = new_value
		chosen_region_changed.emit(new_value)

var forces_pressed: bool = false
