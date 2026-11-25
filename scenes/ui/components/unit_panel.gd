extends Button
class_name UnitPanel

@export var commander_name: Label

@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var mana_l: Label
@export var leadership_l: Label

func set_stats(unit: Unit):
	commander_name.text = unit.name

	attack_l.text = str(unit.final_attack)
	defence_l.text = str(unit.final_defence)
	speed_l.text = str(unit.final_speed)
	mana_l.text = str(unit.final_mana)
	leadership_l.text = str(unit.final_leadership)
