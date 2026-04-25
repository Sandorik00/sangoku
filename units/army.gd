extends Resource
class_name Army

@export_group("info")
@export var name: String
@export var portrait: Texture2D
@export var sprite: AtlasTexture
@export var clazz: String

@export_group("stats")
@export var attack: int
@export var defence: int
@export var speed: int
@export var mana: int
@export var attack_range: int
@export var morale: int
@export var number_of_troops: int

# @export_group("skills")
# @export var passive: String
# @export var abilities: Array[String]
