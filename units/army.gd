extends Resource
class_name Army

@export_group("info")
@export var id: int = -1
@export var name: String
@export var portrait: Texture2D
@export var sprite: AtlasTexture
@export var clazz: String
@export var grade: String

@export_group("stats")
@export var attack: int = 0
@export var defence: int = 0
@export var speed: int = 0
@export var mana: int = 0
@export var attack_range: int = 0
@export var morale: int = 0
@export var number_of_troops: int = 0

# @export_group("skills")
# @export var passive: String
# @export var abilities: Array[String]
