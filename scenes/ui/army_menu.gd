extends Control
class_name ArmyMenu

enum ARMY_MENU_TABS {
	INFO,
	ABILITIES,
	EQUIP,
}

@export var unit_panel_ps: PackedScene
@export var unit_list_ui: VBoxContainer
@export var current_tab_scene: ArmyMenuTab

@export var close_btn: Button

@export_category("Tabs")
@export var info_btn: Button
@export var abilities_btn: Button
@export var equip_btn: Button
@export var tab_container: VBoxContainer

@export var info_tab_ps: PackedScene

var selected_unit: Unit
var current_tab: ARMY_MENU_TABS = ARMY_MENU_TABS.INFO

func _ready():
	close_btn.pressed.connect(_on_close_btn_pressed)

	info_btn.pressed.connect(_on_tab_switched.bind(ARMY_MENU_TABS.INFO))
	abilities_btn.pressed.connect(_on_tab_switched.bind(ARMY_MENU_TABS.ABILITIES))
	equip_btn.pressed.connect(_on_tab_switched.bind(ARMY_MENU_TABS.EQUIP))

func add_units(units_d: UnitsStateDictionary):
	if units_d.is_empty(): return

	selected_unit = units_d.get_by_key(0)

	if selected_unit:
		_refresh_ui()

	for i in units_d.keys().size():
		var u = units_d.get_by_key(i)
		var unit_panel: UnitPanel = unit_panel_ps.instantiate()

		unit_panel.set_stats(u)
		unit_panel.pressed.connect(_on_unit_pressed.bind(u))
		unit_list_ui.add_child(unit_panel)

func _refresh_ui():
	current_tab_scene.refresh_ui(selected_unit)

func _on_unit_pressed(unit: Unit):
	selected_unit = unit
	_refresh_ui()

func _on_close_btn_pressed():
	UIState.army_menu_opened = false

func _on_tab_switched(tab: ARMY_MENU_TABS):
	if current_tab == tab: return

	current_tab = tab
	current_tab_scene.queue_free()

	match current_tab:
		ARMY_MENU_TABS.INFO:
			current_tab_scene = info_tab_ps.instantiate()

		_:
			current_tab_scene = info_tab_ps.instantiate()
			
	current_tab_scene.refresh_ui(selected_unit)
	tab_container.add_child(current_tab_scene)
