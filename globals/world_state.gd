extends Node

var default_commander: Commander = preload("uid://cvtoav134qx88")

var PLAYER_UNITS: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({})
var PLAYER_COMMANDERS: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({
	0: default_commander.duplicate(),
	1: default_commander.duplicate(),
})
var PLAYER_ARMIES: Utils.UnitsStateDictionary = Utils.UnitsStateDictionary.new({})
