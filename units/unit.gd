extends Node2D
class_name Unit

var commander: Commander
var army: Army

var unit_name: String
var portrait: Texture2D
var sprite: Texture2D

var attack: int
var defence: int
var speed: int
var morale: int
var mana: int
var attack_range: int
var troops: int
var initiative: int

func _ready():
	if not army: return

	var commander_stats = commander
	if not commander:
		commander_stats = Commander.new()

	unit_name = commander_stats.name if not commander_stats.name.is_empty() else army.name
	portrait = commander_stats.portrait if commander_stats.portrait else army.portrait
	sprite = commander_stats.sprite if commander_stats.sprite else army.sprite

	attack = army.attack + commander_stats.attack
	defence = army.defence + commander_stats.defence
	speed = army.speed + commander_stats.speed
	morale = army.morale
	mana = army.mana + commander_stats.mana
	attack_range = army.attack_range
	troops = army.number_of_troops
	initiative = army.speed + commander_stats.speed
