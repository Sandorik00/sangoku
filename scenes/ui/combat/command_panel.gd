extends Control
class_name CommandPanel

signal skill_pressed(skill: Skill)
signal consumable_pressed(consumable: Consumable)

var skill_icon_ps: PackedScene = preload("uid://dy4wllm7v3xxu")
var item_icon_ps: PackedScene = preload("uid://b4ww83eyopwi0")

@export_category("Info")
@export var portrait: TextureRect
@export var name_label: Label
@export var end_turn_button: Button

@export_category("Basic stats")
@export var attack: Label
@export var defence: Label
@export var speed: Label
@export var attack_range: Label

@export_category("Uniq stats")
@export var morale: Label
@export var morale_slider: HSlider
@export var mana: Label
@export var mana_slider: HSlider

@export_category("Containers")
@export var skills_container: HBoxContainer
@export var consumables_container: HBoxContainer
@export var equip_container: HBoxContainer

var unit_data: Unit = null

var number_of_skill_icons: int = 9
var number_of_consumable_icons: int = 6
var number_of_equip_icons: int = 4

var skill_icons: Dictionary[int, Button] = {}
var skill_index_to_skill: Dictionary[int, Skill] = {}

var consumables_icons: Dictionary[int, Button] = {}
var consumables_index_to_consumable: Dictionary[int, Consumable] = {}

func _init():
	CombatData.unit_data_changed.connect(_fill_unit_data)
	hide()

func _ready():
	for i in range(number_of_skill_icons):
		var skill_icon: Button = skill_icon_ps.instantiate()

		skill_icon.pressed.connect(_skill_icon_pressed.bind(i))

		skill_icons.set(i, skill_icon)
		skill_icon.hide()
		skills_container.add_child(skill_icon)

	for i in range(number_of_equip_icons):
		var equip_icon: Button = item_icon_ps.instantiate()

		# skill_icon.pressed.connect(_skill_icon_pressed.bind(i))

		# skill_icons.set(i, equip_icon)
		# equip_icon.hide()
		equip_container.add_child(equip_icon)

	for i in range(number_of_consumable_icons):
		var consumable_icon: Button = item_icon_ps.instantiate()

		consumable_icon.pressed.connect(_consumable_icon_pressed.bind(i))

		consumables_icons.set(i, consumable_icon)
		consumable_icon.hide()
		consumables_container.add_child(consumable_icon)

func _skill_icon_pressed(index: int):
	skill_pressed.emit(skill_index_to_skill.get(index))

func _consumable_icon_pressed(index: int):
	assert(unit_data != null, "Why is unit data empty in command panel")

	unit_data.consumables.remove_at(index)
	consumable_pressed.emit(consumables_index_to_consumable.get(index))
	CombatData.panel_unit_data = unit_data

func _fill_unit_data(data: Unit):
	unit_data = data

	skill_index_to_skill.clear()
	for si: Button in skill_icons.values():
		si.hide()
		si.icon = null

	consumables_index_to_consumable.clear()
	for ci: Button in consumables_icons.values():
		ci.hide()
		ci.icon = null

	portrait.texture = data.portrait
	name_label.text = data.name

	attack.text = str(data.attack)
	defence.text = str(data.defence)
	speed.text = str(data.speed)
	attack_range.text = str(data.attack_range)

	morale.text = str(data.morale)
	morale_slider.value = data.morale
	mana.text = str(data.mana)
	mana_slider.value = data.mana

	for i in range(number_of_skill_icons):
		var skill = data.skills.get(i) if data.skills.size() > i else null
		var skill_icon: Button = skill_icons.get(i)

		if skill == null:
			skill_icon.disabled = true
		else:
			skill_icon.disabled = false
			skill_index_to_skill.set(i, skill)
			skill_icon.icon = (skill as Skill).icon

		skill_icon.show()

	for i in range(number_of_consumable_icons):
		var consumable = data.consumables.get(i) if data.consumables.size() > i else null
		var consumable_icon: Button = consumables_icons.get(i)

		if consumable == null:
			consumable_icon.disabled = true
		else:
			consumable_icon.disabled = false
			consumables_index_to_consumable.set(i, consumable)
			consumable_icon.icon = (consumable as Consumable).icon

		consumable_icon.show()

	if hidden:
		show()
