extends Resource
class_name Commander

@export_group("info")
@export var name: String
@export var portrait: Image

@export_group("stats")
@export var attack: int
@export var defence: int
@export var speed: int
@export var leadership: int
@export var mana: int

# @export_group("skills")
# @export var passive: String
# @export var abilities: Array[String]

# @export_group("items")
# @export var equipped_items: Array[String]
