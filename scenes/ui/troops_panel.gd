extends HBoxContainer
class_name TroopsPanel

@export var unit_name_l: Label
@export var troops_l: Label
@export var max_l: Label
@export var confirm_btn: Button
@export var troops_slider: HSlider

var current_unit: Unit

func _ready() -> void:
	confirm_btn.pressed.connect(_on_confirm_pressed)
	troops_slider.value_changed.connect(_on_slider_value_changed)

func setup_ui(unit: Unit):
	unit_name_l.text = unit.name
	troops_l.text = str(unit.troops)
	max_l.text = str(unit.max_troops)

	current_unit = unit

	troops_slider.min_value = 1
	troops_slider.max_value = unit.max_troops

	troops_slider.set_value_no_signal(unit.troops)

func _on_confirm_pressed():
	if current_unit.troops == int(troops_slider.value): return
	
	WorldActions.refill_troops(WorldState.PLAYER_DATA, current_unit, int(troops_slider.value))
	WorldState.player_data_changed.emit()

func _on_slider_value_changed(value: float):
	troops_l.text = str(int(value))
