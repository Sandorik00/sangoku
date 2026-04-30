extends Control

@export_category("Info")
@export var portrait: TextureRect
@export var name_label: Label

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

func _init():
	CombatData.unit_data_changed.connect(_fill_unit_data)
	hide()

func _fill_unit_data(data: Unit):
	portrait.texture = data.portrait
	name_label.text = data.unit_name

	attack.text = str(data.attack)
	defence.text = str(data.defence)
	speed.text = str(data.speed)
	attack_range.text = str(data.attack_range)

	morale.text = str(data.morale)
	morale_slider.value = data.morale
	mana.text = str(data.mana)
	mana_slider.value = data.mana

	show()
