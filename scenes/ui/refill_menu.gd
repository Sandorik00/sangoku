extends Control
class_name RefillMenu

@export var troops_panel_ps: PackedScene
@export var troops_container: VBoxContainer
@export var close_btn: Button

func _ready() -> void:
	close_btn.pressed.connect(_on_close_btn_pressed)

func add_units(units_d: UnitsStateDictionary):
	for i in units_d.keys().size():
		var u: Unit = units_d.get_by_key(i)
		var troops_panel: TroopsPanel = troops_panel_ps.instantiate()

		troops_panel.setup_ui(u)
		troops_container.add_child(troops_panel)

func _on_close_btn_pressed():
	UIState.refill_menu_opened = false
