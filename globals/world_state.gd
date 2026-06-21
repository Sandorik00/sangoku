extends Node

var default_commander: Commander = preload("uid://cvtoav134qx88")
var default_enemy_commander: Commander = preload("uid://c7djxq3ycce4")
var default_enemy_army: Army = preload("uid://ccflaedfaseyi")

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
var OTHER_UNITS: Dictionary[Types.TEAMS, Dictionary] = {}

var DEFAULT_ENEMY_UNITS: Dictionary[int, Unit] = {
	0: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
	1: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
	2: Unit.new(Types.TEAMS.RED, default_enemy_commander.duplicate(), default_enemy_army.duplicate()),
}
