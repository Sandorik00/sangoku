extends Node

signal hiring_army(army: Army, cost: int, region_armies_after_hire: Array[Army])

func _ready():
	hiring_army.connect(_on_hiring_army)

func _on_hiring_army(army: Army, cost: int, region_armies_after_hire: Array[Army]):
	if WorldState.PLAYER_DATA.money >= cost:
		WorldState.PLAYER_DATA.money -= cost
		WorldState.PLAYER_ARMIES.set_last(army)
		UIState.update_regions_data(region_armies_after_hire)
		print("Hired: " + army.name)
	else: print("This is a bug!!")
