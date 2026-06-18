extends Panel
class_name MenuPanel

@export var system_btn: TextureButton
@export var items_btn: TextureButton
@export var army_btn: Button

func _ready():
	system_btn.pressed.connect(_on_system_pressed)
	items_btn.pressed.connect(_on_items_pressed)
	army_btn.pressed.connect(_on_army_pressed)

func _on_system_pressed():
	pass

func _on_items_pressed():
	pass

func _on_army_pressed():
	UIState.army_menu_opened = true
