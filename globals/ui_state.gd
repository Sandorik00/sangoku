extends Node

signal chosen_region_changed(region: Region)
signal region_action_changed(type: Types.REGION_ACTION_TYPE)

# menu signals
signal menu_army_switched(opened: bool)

var all_regions_data: Dictionary[int, Array]

var armies_for_hire: Array[Army] = []

@onready var default_units_for_hire: UnitsByRegions = preload("uid://c52jtoi4mjys8")

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

func _ready():
	chosen_region_changed.connect(_on_chosen_region_changed)

	var paths := Utils.collect_resources("res://regions/resources/unit_data")
	for path in paths:
		var res: UnitsByRegions = ResourceLoader.load(path, "UnitsByRegions")
		var armies = res.units_in_store

		all_regions_data.set(res.region_id, armies)

func _on_chosen_region_changed(region: Region):
	if not region:
		armies_for_hire = []
		return

	armies_for_hire = all_regions_data.get(region.id, default_units_for_hire.units_in_store)

# menu panel actions
var army_menu_opened: bool = false :
	set(new_value):
		army_menu_opened = new_value
		menu_army_switched.emit(new_value)
