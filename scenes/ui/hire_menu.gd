extends Control
class_name HireMenu

@export var unit_panel_ps: PackedScene
@export var unit_list_ui: VBoxContainer

@export var hire_btn: Button

@export_group("Short info")
@export var portrait_tr: TextureRect
@export var class_l: Label
@export var grade_l: Label
@export var troops_l: Label
@export var cost_l: Label

@export_group("Stats")
@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var attack_range_l: Label
@export var mana_l: Label
@export var morale_l: Label

var armies: Dictionary[int, Army] = {}
var selected_army: Army
var selected_army_index: int = -1
var selected_army_cost: int = -1

var army_panels: Dictionary[int, ArmyPanel] = {}

func _ready():
	hire_btn.pressed.connect(_on_hire_btn_pressed)

func add_armies(armies_a: Array[Army]):
	if armies_a.is_empty(): return

	for i in armies_a.size():
		armies.set(i, armies_a.get(i))

	selected_army = armies.get(0)
	selected_army_index = 0
	selected_army_cost = selected_army.number_of_troops * selected_army.base_cost
	_validate_hire_btn()
	if selected_army:
		_refresh_ui()

	for i in armies.keys().size():
		var army = armies.get(i)
		var army_panel: ArmyPanel = unit_panel_ps.instantiate()

		army_panel.set_stats(army)
		army_panel.pressed.connect(_on_army_pressed.bind(army, i))
		army_panels.set(i, army_panel)
		unit_list_ui.add_child(army_panel)

func _on_army_pressed(army: Army, index: int):
	selected_army = army
	selected_army_index = index
	selected_army_cost = selected_army.number_of_troops * selected_army.base_cost
	_validate_hire_btn()
	_refresh_ui()

func _refresh_ui():
	portrait_tr.texture = selected_army.portrait
	class_l.text = selected_army.clazz
	grade_l.text = selected_army.grade
	troops_l.text = str(selected_army.number_of_troops)
	cost_l.text = str(selected_army_cost)

	attack_l.text = str(selected_army.attack)
	defence_l.text = str(selected_army.defence)
	speed_l.text = str(selected_army.speed)
	attack_range_l.text = str(selected_army.attack_range)
	mana_l.text = str(selected_army.mana)
	morale_l.text = str(selected_army.morale)

func _on_hire_btn_pressed():
	var curr_panel: ArmyPanel = army_panels.get(selected_army_index)
	army_panels.erase(selected_army_index)
	curr_panel.queue_free()

	armies.erase(selected_army_index)

	WorldActions.hiring_army.emit(selected_army, selected_army_cost, armies.values())

	# TODO: wait for Godot 4.9 for `get` issue fixed
	if armies.keys().is_empty():
		selected_army_index = -1
		selected_army = null
		selected_army_cost = -1
	else:
		selected_army_index = armies.keys().get(0)
		selected_army = armies.get(selected_army_index)
		selected_army_cost = selected_army.number_of_troops * selected_army.base_cost

	_validate_hire_btn()

	if selected_army:
		_refresh_ui()
	else:
		UIState.current_region_action = Types.REGION_ACTION_TYPE.NONE

func _validate_hire_btn():
	if WorldState.PLAYER_DATA.money < selected_army_cost:
		hire_btn.disabled = true
	else: hire_btn.disabled = false
