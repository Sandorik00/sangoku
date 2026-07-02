extends Panel
class_name FactionsTurnUI

@export var faction_name_l: Label

func set_faction(faction_name: String):
	faction_name_l.text = faction_name
