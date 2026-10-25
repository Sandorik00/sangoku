extends Node

signal player_data_changed()

var player_faction: FactionsState.FACTIONS = FactionsState.FACTIONS.RAVINE_HUMANS

var region_icon_ps: PackedScene = preload("uid://si1chjm11vou")

func _ready() -> void:
	var region_icon_nodes = get_tree().get_nodes_in_group("RegionIcons")
	for rin: RegionIcon in region_icon_nodes:
		ALL_REGION_ICONS.set(rin.res.id, rin)

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

	var faction_data_paths: Array[String] = Utils.collect_resources("res://campaigns/free_mode")
	for path in faction_data_paths:
		var res: FactionData = ResourceLoader.load(path, "FactionData")

		FACTIONS_TO_DATA.set(res.faction, res)
		if res.faction == player_faction:
			PLAYER_DATA = res
			PLAYER_UNITS = res.units

# player
## { commander_id: [Unit] }
var DEFAULT_ENEMY_UNITS: UnitsStateDictionary = UnitsStateDictionary.new({
	0: preload("uid://cb8vsyda8rl5e"),
	1: preload("uid://c4fqm3lvds4y8"),
})

# regions
## Dictionary[FactionsState.FACTIONS, Array[RegionIcon]]
var DEFAULT_REGIONS: Dictionary[FactionsState.FACTIONS, Array] = {}

var ALL_PROVINCES: Dictionary[int, Province] = {}
var ALL_REGIONS: Dictionary[int, Region] = {}

var ALL_REGION_ICONS: Dictionary[int, RegionIcon] = {}

var PLAYER_DATA: FactionData = null
var PLAYER_UNITS: UnitsStateDictionary = null
var FACTIONS_TO_DATA: Dictionary[FactionsState.FACTIONS, FactionData] = {}
