extends Control
class_name CommandPanel

signal skill_pressed(skill: Skill)

var skill_icon_ps: PackedScene = preload("uid://dy4wllm7v3xxu")

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

var number_of_skill_icons: int = 9

var skill_icons: Dictionary[int, Button] = {}
var skill_index_to_skill: Dictionary[int, Skill] = {}

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

func _skill_icon_pressed(index: int):
	skill_pressed.emit(skill_index_to_skill.get(index))

func _fill_unit_data(data: Unit):
	skill_index_to_skill.clear()
	for si: Button in skill_icons.values():
		si.hide()
		si.icon = null

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

	if hidden:
		show()
