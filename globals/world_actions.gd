extends Node

signal hiring_army(army: Army)

func _ready():
	hiring_army.connect(_on_hiring_army)

func _on_hiring_army(army: Army):
	WorldState.PLAYER_COMMANDERS.set_last(army)
	print("Hired: " + army.name)
