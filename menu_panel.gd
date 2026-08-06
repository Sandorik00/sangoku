extends Panel
class_name MenuPanel

@export_group("Buttons")
@export var system_btn: TextureButton
@export var items_btn: TextureButton
@export var army_btn: Button
@export var troops_btn: Button

@export var end_turn_btn: Button

@export_group("Info")
@export var money_l: Label

func _ready():
	system_btn.pressed.connect(_on_system_pressed)
	items_btn.pressed.connect(_on_items_pressed)
	army_btn.pressed.connect(_on_army_pressed)
	troops_btn.pressed.connect(_on_troops_pressed)

	end_turn_btn.pressed.connect(_on_end_turn_pressed)

	money_l.text = str(WorldState.PLAYER_DATA.money)
	WorldState.player_data_changed.connect(refresh_ui)

func refresh_ui():
	money_l.text = str(WorldState.PLAYER_DATA.money)

func _on_system_pressed():
	pass

func _on_items_pressed():
	pass

func _on_army_pressed():
	UIState.army_menu_opened = true

func _on_troops_pressed():
	UIState.refill_menu_opened = true

func _on_end_turn_pressed():
	WorldTurnLogic.turn_end.emit()
