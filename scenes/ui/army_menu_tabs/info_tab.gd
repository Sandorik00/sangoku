extends ArmyMenuTab
class_name InfoTab

@export_category("Stats")
@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var mana_l: Label
@export var leadership_l: Label

@export_category("Army")
@export var clazz_l: Label
@export var level_l: Label
@export var troops_l: Label

func refresh_ui(unit: Unit):
	if not unit: return

	attack_l.text = str(unit.final_attack)
	defence_l.text = str(unit.final_defence)
	speed_l.text = str(unit.final_speed)
	mana_l.text = str(unit.final_mana)
	leadership_l.text = str(unit.final_leadership)

	clazz_l.text = str(unit.clazz)
	level_l.text = str(unit.level)
	troops_l.text = str(unit.troops)
