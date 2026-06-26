extends Node2D

var base_region_pos: Vector2 = Vector2(200, 100)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if UIState.current_region_action == Types.REGION_ACTION_TYPE.NONE:
				UIState.chosen_region = null
			else:
				UIState.current_region_action = Types.REGION_ACTION_TYPE.NONE

func _ready() -> void:
	var all_regions: Array[RegionIcon] = []

	for a in WorldState.DEFAULT_REGIONS.values():
		all_regions.append_array(a)

	for i in all_regions.size():
		var new_pos: Vector2 = (base_region_pos * i) + base_region_pos
		var region: RegionIcon = all_regions.get(i)

		region.position = new_pos
		add_child(region)

