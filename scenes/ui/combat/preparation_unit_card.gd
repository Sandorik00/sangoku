extends PanelContainer
class_name PreparationUnitCard

@export var name_l: Label
@export var portrait_tr: TextureRect
@export var btn: Button

var unit_entity: SanGrid.GridEntity

var modulate_color: Color = Color(1, 1, 1, 0):
	set(new_value):
		modulate_color = new_value
		apply_modulation()

var modulate_dim: Color = Color(0, 0, 0, 1):
	set(new_value):
		modulate_dim = new_value
		apply_modulation()

func prepare():
	name_l.text = unit_entity.unitNode.unit_data.name
	portrait_tr.texture = unit_entity.unitNode.unit_data.portrait

func highlight():
	modulate_color = Color(0.5, 1, 0.5, 0)

func blur():
	modulate_color = Color(1, 1, 1, 0)

func dim():
	modulate_dim = Color(0, 0, 0, 0.5)

func undim():
	modulate_dim = Color(0, 0, 0, 1)

func apply_modulation():
	modulate = modulate_color + modulate_dim
