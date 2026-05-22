extends Control

@export var actionsBoxPS: PackedScene
@export var castlesBoxPS: PackedScene
@export var region_action_ui_ps: PackedScene

var actionsBox: RegionActionsBox
var castlesBox: Panel

func _ready():
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

	# region actions
	UIState.region_action_changed.connect(_on_region_action_changed)

func _on_chosen_region_changed(region: Region):
	if (not region):
		if actionsBox:
			actionsBox.queue_free()
			actionsBox = null
		if castlesBox:
			castlesBox.queue_free()
			castlesBox = null
		return

	if (actionsBox):
		actionsBox.queue_free()
		actionsBox = null
		castlesBox.queue_free()
		castlesBox = null

	actionsBox = actionsBoxPS.instantiate() as RegionActionsBox
	castlesBox = castlesBoxPS.instantiate() as Panel

	actionsBox.region_name_l.text = region.name

	for action in Types.DEFAULT_REGION_ACTIONS:
		var region_action_ui: RegionActionUI = region_action_ui_ps.instantiate()
		region_action_ui.action_type = action

		actionsBox.actions_container.add_child(region_action_ui)

	add_child(actionsBox)

	castlesBox.add_castles(region.castle_count)
	add_child(castlesBox)

func _on_region_action_changed(type: Types.REGION_ACTION_TYPE):
	print(type)
