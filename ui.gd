extends Control

@export var actionsBoxPS: PackedScene
@export var castlesBoxPS: PackedScene

var actionsBox: Panel
var castlesBox: Panel

func _ready():
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

func _on_chosen_region_changed(region: Region):
	if (not region):
		actionsBox.queue_free()
		actionsBox = null
		castlesBox.queue_free()
		castlesBox = null
		return

	if (actionsBox):
		actionsBox.queue_free()
		actionsBox = null
		castlesBox.queue_free()
		castlesBox = null

	actionsBox = actionsBoxPS.instantiate() as Panel
	castlesBox = castlesBoxPS.instantiate() as Panel

	var label = Label.new()
	label.text = region.name

	actionsBox.add_child(label)
	add_child(actionsBox)

	castlesBox.add_castles(region.castle_count)
	add_child(castlesBox)
