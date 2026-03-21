extends Panel

@export var system_btn: TextureButton
@export var items_btn: TextureButton
@export var forces_btn: TextureButton

func _ready():
	system_btn.pressed.connect(_on_system_pressed)
	items_btn.pressed.connect(_on_items_pressed)
	forces_btn.pressed.connect(_on_forces_pressed)

func _on_system_pressed():
	pass

func _on_items_pressed():
	pass

func _on_forces_pressed():
	pass
