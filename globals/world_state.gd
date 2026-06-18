extends Node

var default_commander: Commander = preload("uid://cvtoav134qx88")

var PLAYER_COMMANDERS: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({
	0: default_commander.duplicate(),
	1: default_commander.duplicate(),
})
var PLAYER_ARMIES: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({})

## { commander_id: [Unit] }
var PLAYER_UNITS: Dictionary[int, Unit] = {
	0: Unit.new(PLAYER_COMMANDERS.get_by_key(0)),
	1: Unit.new(PLAYER_COMMANDERS.get_by_key(1)),
}
