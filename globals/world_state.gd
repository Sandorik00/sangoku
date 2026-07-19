extends Node

var player_faction: FactionsState.FACTIONS = FactionsState.FACTIONS.RAVINE_HUMANS

var region_icon_ps: PackedScene = preload("uid://si1chjm11vou")

var default_commander: Commander = preload("uid://cvtoav134qx88")
var default_enemy_commander: Commander = preload("uid://c7djxq3ycce4")
var default_enemy_army: Army = preload("uid://ccflaedfaseyi")

var san_fd: FactionData = preload("uid://b11lrqc3hslkx")
var rombus_fd: FactionData = preload("uid://bg543dst24jwa")
var rik_fd: FactionData = preload("uid://ccw2wet6o1bwv")

func _ready() -> void:
	ALL_REGION_ICONS.assign(get_tree().get_nodes_in_group("RegionIcons"))

	var regions_paths := Utils.collect_resources("res://regions/resources/region_res/free_mode/regions")
	for path in regions_paths:
		var res: Region = ResourceLoader.load(path, "Region")

		ALL_REGIONS.set(res.id, res)

	var provinces_paths := Utils.collect_resources("res://regions/resources/region_res/free_mode/provinces")
	for path in provinces_paths:
		var res: Province = ResourceLoader.load(path, "Province")

		var regions = res.regions.map(func(key): return ALL_REGIONS.get(key)) as Array[Region]
		for r in regions:
			r.province = res

		ALL_PROVINCES.set(res.id, res)

	for f in FactionsState.FACTIONS.values():
		FACTIONS_TO_DATA.set(f, rik_fd)

# player
var PLAYER_COMMANDERS: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({
	0: default_commander.duplicate(),
	1: default_commander.duplicate(),
})
var PLAYER_ARMIES: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({})

## { commander_id: [Unit] }
var PLAYER_UNITS: Dictionary[int, Unit] = {
	0: Unit.new(Types.TEAMS.BLUE, PLAYER_COMMANDERS.get_by_key(0)),
	1: Unit.new(Types.TEAMS.BLUE, PLAYER_COMMANDERS.get_by_key(1)),
}

# enemies, neutrals, others per se
var OTHER_UNITS: Dictionary[FactionsState.FACTIONS, Dictionary] = {}

var DEFAULT_ENEMY_UNITS: Dictionary[int, Unit] = {
	0: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
	1: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
	2: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
}

# regions
## Dictionary[FactionsState.FACTIONS, Array[RegionIcon]]
var DEFAULT_REGIONS: Dictionary[FactionsState.FACTIONS, Array] = {}

var ALL_PROVINCES: Dictionary[int, Province] = {}
var ALL_REGIONS: Dictionary[int, Region] = {}

var ALL_REGION_ICONS: Array[RegionIcon] = []

var FACTIONS_TO_DATA: Dictionary[FactionsState.FACTIONS, FactionData] = {}
