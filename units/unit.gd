extends Resource
class_name Unit

var commander: Commander
var army: Army

var name: String
var portrait: Texture2D
var sprite: AtlasTexture

var attack: int
var defence: int
var speed: int
var morale: int
var mana: int
var leadership: int
var attack_range: int
var troops: int
var initiative: int
var movement: int

var validUnit: bool = false
var team: Types.TEAMS = Types.TEAMS.RED
var enemies: Types.TEAM_MAPPING = Types.TEAM_MAPPING.RED

func _init(_commander: Commander, _army: Army = null) -> void:
	assert(_commander, "Unit must have a commander!")
	
	commander = _commander
	army = _army

	self.calculate()

func calculate():
	validUnit = false
	if not commander: return

	var army_stats = army
	if not army_stats:
		army_stats = Army.new()
	
	name = commander.name if not commander.name.is_empty() else army_stats.name
	portrait = commander.portrait if commander.portrait else army_stats.portrait
	sprite = commander.sprite if commander.sprite else army_stats.sprite

	attack = army_stats.attack + commander.attack
	defence = army_stats.defence + commander.defence
	speed = army_stats.speed + commander.speed
	morale = army_stats.morale
	mana = army_stats.mana + commander.mana
	leadership = commander.leadership
	attack_range = max(army_stats.attack_range, 1)
	troops = army_stats.number_of_troops
	initiative = army_stats.speed + commander.speed
	movement = speed

	validUnit = true
