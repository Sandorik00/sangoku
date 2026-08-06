extends Node

signal chosen_region_changed(region: Region)
signal region_action_changed(type: Types.REGION_ACTION_TYPE)

# menu signals
signal menu_army_switched(opened: bool)
signal menu_refill_switched(opened: bool)

var chosen_region: Region :
	set(new_value):
		chosen_region = new_value
		chosen_region_changed.emit(new_value)

var forces_pressed: bool = false

# actions with region
var current_region_action: Types.REGION_ACTION_TYPE = Types.REGION_ACTION_TYPE.NONE :
	set(new_value):
		current_region_action = new_value
		region_action_changed.emit(new_value)

# menu panel actions
var army_menu_opened: bool = false :
	set(new_value):
		army_menu_opened = new_value
		menu_army_switched.emit(new_value)

var refill_menu_opened: bool = false :
	set(new_value):
		refill_menu_opened = new_value
		menu_refill_switched.emit(new_value)
