extends Control
class_name HireMenu

@export var unit_panel_ps: PackedScene
@export var unit_list_ui: VBoxContainer

@export var hire_btn: Button

@export_group("Short info")
@export var portrait_tr: TextureRect
@export var class_l: Label
@export var level_l: Label
@export var troops_l: Label
@export var cost_l: Label

@export_group("Stats")
@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var attack_range_l: Label
@export var mana_l: Label
@export var morale_l: Label

var units_for_hire: Dictionary = {}

var selected_unit: Unit = null
var selected_unit_index: int = -1
var selected_unit_cost: int = -1

var unit_panels: Dictionary[int, UnitPanel] = {}

func _ready():
	hire_btn.pressed.connect(_on_hire_btn_pressed)

	units_for_hire = HireLogic.get_units_for_faction(WorldState.player_faction)

	if units_for_hire.is_empty(): return

	selected_unit_index = units_for_hire.keys().get(0)
	selected_unit = units_for_hire.get(selected_unit_index)
	selected_unit_cost = selected_unit.troops * 1
	_validate_hire_btn()

	if selected_unit:
		_refresh_ui()

	for k in units_for_hire.keys():
		var unit: Unit = units_for_hire.get(k)
		var unit_panel: UnitPanel = unit_panel_ps.instantiate()

		unit_panel.set_stats(unit)
		unit_panel.pressed.connect(_on_unit_pressed.bind(unit, k))
		unit_panels.set(k, unit_panel)
		unit_list_ui.add_child(unit_panel)

func _on_unit_pressed(unit: Unit, index: int):
	selected_unit = unit
	selected_unit_index = index
	selected_unit_cost = selected_unit.troops * 1

	_validate_hire_btn()
	_refresh_ui()

func _refresh_ui():
	portrait_tr.texture = selected_unit.portrait
	class_l.text = selected_unit.clazz
	troops_l.text = str(selected_unit.troops)
	cost_l.text = str(selected_unit_cost)

	attack_l.text = str(selected_unit.attack)
	defence_l.text = str(selected_unit.defence)
	speed_l.text = str(selected_unit.speed)
	attack_range_l.text = str(selected_unit.attack_range)
	mana_l.text = str(selected_unit.mana)
	morale_l.text = str(selected_unit.morale)

func _on_hire_btn_pressed():
	var curr_panel: UnitPanel = unit_panels.get(selected_unit_index)
	unit_panels.erase(selected_unit_index)
	curr_panel.queue_free()

	HireLogic.hire_unit(WorldState.player_faction, selected_unit_index)
	units_for_hire.erase(selected_unit_index)

	# TODO: wait for Godot 4.9 for `get` issue fixed
	if units_for_hire.is_empty():
		selected_unit_index = -1
		selected_unit = null
		selected_unit_cost = -1
	else:
		selected_unit_index = units_for_hire.keys().get(0)
		selected_unit = units_for_hire.get(selected_unit_index)
		selected_unit_cost = selected_unit.troops * 1

	_validate_hire_btn()

	if selected_unit:
		_refresh_ui()
	else:
		UIState.current_region_action = Types.REGION_ACTION_TYPE.NONE

func _validate_hire_btn():
	if selected_unit_index == -1:
		hire_btn.disabled = true
		return

	if WorldState.PLAYER_DATA.money < selected_unit_cost:
		hire_btn.disabled = true
	else: hire_btn.disabled = false
