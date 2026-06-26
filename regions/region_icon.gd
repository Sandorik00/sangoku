extends TextureButton
class_name RegionIcon

@export var res: Region

func _ready():
	self.pressed.connect(_on_pressed)
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

func _on_pressed() -> void:
	modulate = Color.RED
	UIState.chosen_region = res

func _on_chosen_region_changed(region: Region):
	if (not region or region.id != res.id):
		modulate = Color.WHITE
