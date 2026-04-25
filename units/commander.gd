extends Resource
class_name Commander

@export_group("info")
@export var name: String = ""
@export var portrait: Texture2D
@export var sprite: AtlasTexture

@export_group("stats")
@export var attack: int = 0
@export var defence: int = 0
@export var speed: int = 0
@export var leadership: int = 0
@export var mana: int = 0

# @export_group("skills")
# @export var passive: String
# @export var abilities: Array[String]

# @export_group("items")
# @export var equipped_items: Array[String]
