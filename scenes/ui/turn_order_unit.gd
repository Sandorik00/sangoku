extends TextureRect
class_name TurnOrderUnit

func highlight():
	self.self_modulate = Color(1, 1, 1, 1)

func blur():
	self.self_modulate = Color(0.35, 0.35, 0.35, 0.78)
