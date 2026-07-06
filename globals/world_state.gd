extends Node

var region_icon_ps: PackedScene = preload("uid://si1chjm11vou")

var default_commander: Commander = preload("uid://cvtoav134qx88")
var default_enemy_commander: Commander = preload("uid://c7djxq3ycce4")
var default_enemy_army: Army = preload("uid://ccflaedfaseyi")

var sanland: Region = preload("uid://be1hic0tw0w81")
var rikland: Region = preload("uid://c5vauo0h72mbl")
var redarchive: Region = preload("uid://qit5odxkt08m")
var rombusland: Region = preload("uid://dkvcfpm52co1")

var san_fd: FactionData = preload("uid://b11lrqc3hslkx")
var rombus_fd: FactionData = preload("uid://bg543dst24jwa")
var rik_fd: FactionData = preload("uid://ccw2wet6o1bwv")

func _ready() -> void:
	# temporal regions
	var region_icon: RegionIcon = region_icon_ps.instantiate()
	region_icon.res = sanland
	DEFAULT_REGIONS.set(FactionsState.FACTIONS.SAN, [region_icon])

	region_icon = region_icon_ps.instantiate()
	region_icon.res = rombusland
	DEFAULT_REGIONS.set(FactionsState.FACTIONS.ROMBUS, [region_icon])

	region_icon = region_icon_ps.instantiate()
	region_icon.res = rikland
	var region_icon_2 = region_icon_ps.instantiate()
	region_icon_2.res = redarchive
	DEFAULT_REGIONS.set(FactionsState.FACTIONS.RIK, [region_icon, region_icon_2])

	# temporal factions data
	for f in DEFAULT_REGIONS.keys():
		match f:
			FactionsState.FACTIONS.SAN:
				FACTIONS_TO_DATA.set(FactionsState.FACTIONS.SAN, san_fd)
			FactionsState.FACTIONS.ROMBUS:
				FACTIONS_TO_DATA.set(FactionsState.FACTIONS.ROMBUS, rombus_fd)
			FactionsState.FACTIONS.RIK:
				FACTIONS_TO_DATA.set(FactionsState.FACTIONS.RIK, rik_fd)

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

# TODO: fill
var FACTIONS_TO_DATA: Dictionary[FactionsState.FACTIONS, FactionData] = {}
