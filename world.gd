extends Node2D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if UIState.current_region_action == Types.REGION_ACTION_TYPE.NONE:
				UIState.chosen_region = null
			else:
				UIState.current_region_action = Types.REGION_ACTION_TYPE.NONE
			
