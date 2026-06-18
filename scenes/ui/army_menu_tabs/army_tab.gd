extends ArmyMenuTab
class_name ArmyTab

var selected_unit: Unit

@export var stats_block: VBoxContainer
@export var change_army_btn: Button
@export var unit_list: MarginContainer
@export var unit_list_container: VBoxContainer

@export var army_panel_ps: PackedScene

@export_category("Stats")
@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var mana_l: Label
@export var range_l: Label
@export var morale_l: Label

@export_category("Army")
@export var clazz_l: Label
@export var grade_l: Label
@export var troops_l: Label

func _ready():
	change_army_btn.pressed.connect(_on_change_army_btn_pressed)

func refresh_ui(unit: Unit):
	if not unit: return

	selected_unit = unit

	if unit.army:
		clazz_l.text = str(unit.army.clazz)
		grade_l.text = str(unit.army.grade)
		troops_l.text = str(unit.army.number_of_troops)

		attack_l.text = str(unit.army.attack)
		defence_l.text = str(unit.army.defence)
		speed_l.text = str(unit.army.speed)
		mana_l.text = str(unit.army.mana)
		range_l.text = str(unit.army.attack_range)
		morale_l.text = str(unit.army.morale)

func _on_change_army_btn_pressed():
	stats_block.hide()

	print(WorldState.PLAYER_ARMIES.keys())

	for i in WorldState.PLAYER_ARMIES.keys():
		var army_panel: ArmyPanel = army_panel_ps.instantiate()
		var army: Army = WorldState.PLAYER_ARMIES.get_by_key(i)

		army_panel.set_stats(army)
		army_panel.pressed.connect(_on_army_changed.bind(army))
		unit_list_container.add_child(army_panel)

	unit_list.show()


func _on_army_changed(army: Army):
	unit_list.hide()
	for c in unit_list_container.get_children():
		c.queue_free()

	selected_unit.army = army
	refresh_ui(selected_unit)

	stats_block.show()
