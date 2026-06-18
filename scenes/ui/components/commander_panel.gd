extends Button
class_name CommanderPanel

@export var commander_name: Label

@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var mana_l: Label
@export var leadership_l: Label

func set_stats(unit: Unit):
	commander_name.text = unit.name

	attack_l.text = str(unit.attack)
	defence_l.text = str(unit.defence)
	speed_l.text = str(unit.speed)
	mana_l.text = str(unit.mana)
	leadership_l.text = str(unit.leadership)
