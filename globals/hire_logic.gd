extends Node

var all_units_data: Dictionary[int, Array]
var current_region: int = -1
var armies_for_hire: Array[Army] = []

var armies: Dictionary[int, Army] = {}

@onready var default_units_for_hire: UnitsByRegions = preload("uid://c52jtoi4mjys8")

func _ready() -> void:
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

	var paths := Utils.collect_resources("res://regions/resources/unit_data")
	for path in paths:
		var res: UnitsByRegions = ResourceLoader.load(path, "UnitsByRegions")
		var armies_a = res.units_in_store

		all_units_data.set(res.region_id, armies_a)

func _on_chosen_region_changed(region: Region):
	if not region:
		armies_for_hire = []
		current_region = -1
		armies = {}
		return

	current_region = region.id
	armies_for_hire = all_units_data.get(region.id, default_units_for_hire.units_in_store)

func update_regions_data(region_armies: Array[Army]):
	all_units_data.set(current_region, region_armies)

func add_armies(armies_a: Array[Army]):
	for i in armies_a.size():
		armies.set(i, armies_a.get(i))
