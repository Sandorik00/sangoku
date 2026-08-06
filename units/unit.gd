extends Resource
class_name Unit

@export_group("Info")
@export var id: int = -1
@export var unit_id: int = -1
@export var name: String = ""
@export var portrait: Texture2D = null
@export var sprite: AtlasTexture = null

@export_group("Class info")
@export var clazz: String = ""
@export var level: int = 1

@export_group("Stats")
@export var attack: int = 1
@export var defence: int = 1
@export var speed: int = 1
@export var morale: int = 1
@export var mana: int = 1
@export var leadership: int = 1
@export var attack_range: int = 1
@export var troops: int = 1
@export var initiative: int = 1
@export var movement: int = 3

@export_group("Dynamic stats")
@export var max_troops: int = 1
