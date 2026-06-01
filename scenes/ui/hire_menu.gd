extends Control
class_name HireMenu

@export var unit_panel_ps: PackedScene
@export var unit_list_ui: VBoxContainer

@export var hire_btn: Button

@export_category("Short info")
@export var portrait_tr: TextureRect
@export var class_l: Label
@export var grade_l: Label
@export var troops_l: Label

@export_category("Stats")
@export var attack_l: Label
@export var defence_l: Label
@export var speed_l: Label
@export var attack_range_l: Label
@export var mana_l: Label
@export var morale_l: Label

var armies: Dictionary[int, Army] = {}
var selected_army: Army
var selected_army_index: int = -1

var army_panels: Dictionary[int, ArmyPanel] = {}

func _ready():
	hire_btn.pressed.connect(_on_hire_btn_pressed)

func add_armies(armies_a: Array[Army]):
	for i in armies_a.size():
		armies.set(i, armies_a.get(i))

	selected_army = armies.get(0)
	selected_army_index = 0
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
	_refresh_ui()

func _refresh_ui():
	portrait_tr.texture = selected_army.portrait
	class_l.text = selected_army.clazz
	grade_l.text = selected_army.grade
	troops_l.text = str(selected_army.number_of_troops)

	attack_l.text = str(selected_army.attack)
	defence_l.text = str(selected_army.defence)
	speed_l.text = str(selected_army.speed)
	attack_range_l.text = str(selected_army.attack_range)
	mana_l.text = str(selected_army.mana)
	morale_l.text = str(selected_army.morale)

func _on_hire_btn_pressed():
	WorldActions.hiring_army.emit(selected_army)

	var curr_panel: ArmyPanel = army_panels.get(selected_army_index)
	army_panels.erase(selected_army_index)
	curr_panel.queue_free()

	armies.erase(selected_army_index)

	if armies.keys().is_empty():
		selected_army_index = -1
		selected_army = null
	else:
		selected_army_index = armies.keys().get(0)
		selected_army = armies.get(selected_army_index)

	if selected_army:
		_refresh_ui()
	else:
		UIState.current_region_action = Types.REGION_ACTION_TYPE.NONE
