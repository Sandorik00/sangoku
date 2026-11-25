extends Resource
class_name Unit

@export_group("Info")
@export var id: int = -1
@export var unit_id: int = -1
@export var name: String = ""
@export var portrait: Texture2D = null
@export var sprite: AtlasTexture = null

@export_group("Class info")
@export var clazz: String = ""
@export var level: int = 1

@export_group("Stats")
@export var attack: int = 1
@export var defence: int = 1
@export var speed: int = 1
@export var morale: int = 1
@export var mana: int = 1
@export var leadership: int = 1
@export var attack_range: int = 1
@export var troops: int = 1
@export var initiative: int = 1
@export var movement: int = 3

@export_group("Dynamic stats")
@export var max_troops: int = 1

@export_group("Skills and Items")
@export var skills: Array[Skill] = []
@export var equipment_list: Array[Equipment] = []
@export var consumables: Array[Consumable] = []

var final_attack: int = 0
var final_defence: int = 0
var final_speed: int = 0
var final_morale: int = 0
var final_mana: int = 0
var final_leadership: int = 0
var final_attack_range: int = 0
var final_initiative: int = 0
var final_movement: int = 0

func add_equipment(equipment: Equipment):
	equipment_list.push_back(equipment)
	recalc_final_stats()

func recalc_final_stats():
	final_attack = attack
	final_defence = defence
	final_speed = speed
	final_morale = morale
	final_mana = mana
	final_leadership = leadership
	final_attack_range = attack_range
	final_initiative = initiative
	final_movement = movement

	for equip in equipment_list:
		final_attack += equip.attack
		final_defence += equip.defence
		final_speed += equip.speed
		final_morale += equip.morale
		final_mana += equip.mana
		final_leadership += equip.leadership
		final_attack_range += equip.attack_range
		final_initiative += equip.initiative
		final_movement += equip.movement
