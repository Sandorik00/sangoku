extends Node

signal player_data_changed()

var player_faction: FactionsState.FACTIONS = FactionsState.FACTIONS.RAVINE_HUMANS

var region_icon_ps: PackedScene = preload("uid://si1chjm11vou")

var san_fd: FactionData = preload("uid://b11lrqc3hslkx")
var rombus_fd: FactionData = preload("uid://bg543dst24jwa")
var rik_fd: FactionData = preload("uid://ccw2wet6o1bwv")

func _ready() -> void:
	ALL_REGION_ICONS.assign(get_tree().get_nodes_in_group("RegionIcons"))

	var regions_paths: Array[String] = Utils.collect_resources("res://regions/resources/region_res/free_mode/regions")
	for path in regions_paths:
		var res: Region = ResourceLoader.load(path, "Region")

		ALL_REGIONS.set(res.id, res)

	var provinces_paths: Array[String] = Utils.collect_resources("res://regions/resources/region_res/free_mode/provinces")
	for path in provinces_paths:
		var res: Province = ResourceLoader.load(path, "Province")

		var regions = res.regions.map(func(key): return ALL_REGIONS.get(key)) as Array[Region]
		for r in regions:
			r.province = res

		ALL_PROVINCES.set(res.id, res)

	for f in FactionsState.FACTIONS.values():
		if f == player_faction:
			FACTIONS_TO_DATA.set(f, san_fd)
			continue
		FACTIONS_TO_DATA.set(f, rik_fd)

# player
## { commander_id: [Unit] }
var DEFAULT_ENEMY_UNITS: UnitsStateDictionary = UnitsStateDictionary.new()

# regions
## Dictionary[FactionsState.FACTIONS, Array[RegionIcon]]
var DEFAULT_REGIONS: Dictionary[FactionsState.FACTIONS, Array] = {}

var ALL_PROVINCES: Dictionary[int, Province] = {}
var ALL_REGIONS: Dictionary[int, Region] = {}

var ALL_REGION_ICONS: Array[RegionIcon] = []

var PLAYER_DATA: FactionData = san_fd
var PLAYER_UNITS: UnitsStateDictionary = san_fd.units
var FACTIONS_TO_DATA: Dictionary[FactionsState.FACTIONS, FactionData] = {}
