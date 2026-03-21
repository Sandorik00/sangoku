extends TextureButton

@export var res: Region

func _ready():
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

func _on_pressed() -> void:
	modulate = Color.RED
	UIState.chosen_region = res

func _on_chosen_region_changed(region: Region):
	if (not region or region.name != res.name):
		modulate = Color.WHITE
