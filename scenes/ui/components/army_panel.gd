extends Button
class_name ArmyPanel

@export var army_name: Label

@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var attack_range_l: Label
@export var mana_l: Label
@export var morale_l: Label

func set_stats(army: Army):
	army_name.text = army.name

	attack_l.text = str(army.attack)
	defence_l.text = str(army.defence)
	speed_l.text = str(army.speed)
	attack_range_l.text = str(army.attack_range)
	mana_l.text = str(army.mana)
	morale_l.text = str(army.morale)
