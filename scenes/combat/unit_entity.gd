extends Sprite2D
class_name UnitEntity

var unit_data: Unit

## Call before using
func prepare():
	self.texture = unit_data.sprite
