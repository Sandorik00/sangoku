extends Sprite2D
class_name UnitEntity

var unit_data: Unit

var team: Types.TEAMS = Types.TEAMS.RED :
	set(new_value):
		team = new_value
		enemies = Types.TEAMS_MAPPING_TO_MAPPINGS.get(new_value)

var enemies: Types.TEAM_MAPPING = Types.TEAM_MAPPING.RED

## Call before using
func prepare():
	self.texture = unit_data.sprite
