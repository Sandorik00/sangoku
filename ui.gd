extends Control
class_name GlobalUI

@export var world: Node2D
@export var world_camera: Camera2D
@export var sub_viewport: SubViewport

@export_category("Packed scenes")
@export var actionsBoxPS: PackedScene
@export var castlesBoxPS: PackedScene
@export var region_action_ui_ps: PackedScene
@export var hire_menu_ui_ps: PackedScene

@export var combat_ps: PackedScene

@export_category("Menu panel")
@export var menu_panel: MenuPanel
@export var army_menu_ui_ps: PackedScene

@export_category("Turn panels")
@export var factions_turn_ui: FactionsTurnUI

var actionsBox: RegionActionsBox
var castlesBox: Panel
var hire_menu_ui: HireMenu
var army_menu_ui: ArmyMenu

# turn logic
var highlighted_regions: Array[RegionIcon] = []

func _ready():
	UIState.chosen_region_changed.connect(_on_chosen_region_changed)

	## region actions
	UIState.region_action_changed.connect(_on_region_action_changed)

	# menu panel buttons
	UIState.menu_army_switched.connect(_on_menu_army_switched)

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

	var actions_for_region: Array[Types.REGION_ACTION_TYPE] = []
	if region.faction != FactionsState.FACTIONS.SAN:
		actions_for_region.append_array(
			Utils.get_actions_for_relation(FactionsState.get_relation(FactionsState.FACTIONS.SAN, region.faction))
		)

	actions_for_region.append_array(Utils.get_actions_for_property(region, FactionsState.FACTIONS.SAN))

	for action in actions_for_region:
		if action == Types.REGION_ACTION_TYPE.NONE: return

		var region_action_ui: RegionActionUI = region_action_ui_ps.instantiate()
		region_action_ui.action_type = action
		region_action_ui.btn.text = Types.ACTIONS_TEXT.get(action)

		actionsBox.actions_container.add_child(region_action_ui)

	add_child(actionsBox)

	castlesBox.add_castles(region.castle_count)
	add_child(castlesBox)

func _on_region_action_changed(type: Types.REGION_ACTION_TYPE):
	match type:
		Types.REGION_ACTION_TYPE.NONE:
			if hire_menu_ui:
				hire_menu_ui.queue_free()
				hire_menu_ui = null

		Types.REGION_ACTION_TYPE.HIRE_ARMY:
			_show_hire_ui()

		Types.REGION_ACTION_TYPE.ATTACK:
			UIState.chosen_region = null

			WorldTurnLogic.into_combat()

func _show_hire_ui():
	hire_menu_ui = hire_menu_ui_ps.instantiate()

	hire_menu_ui.add_armies(UIState.armies_for_hire)
	add_child(hire_menu_ui)

func _on_menu_army_switched(opened: bool):
	if opened:
		army_menu_ui = army_menu_ui_ps.instantiate()

		army_menu_ui.add_units(WorldState.PLAYER_UNITS)
		add_child(army_menu_ui)
	else:
		army_menu_ui.queue_free()
		army_menu_ui = null

func toggle_on_turn_end(players_turn: bool, faction: FactionsState.FACTIONS):
	if players_turn and factions_turn_ui.visible:
		for r in highlighted_regions:
			r.self_modulate = Color(1, 1, 1, 1)
		highlighted_regions.clear()

		factions_turn_ui.hide()
	else:
		for r in highlighted_regions:
			r.self_modulate = Color(1, 1, 1, 1)
		highlighted_regions.clear()

		var faction_regions = WorldState.DEFAULT_REGIONS.get(faction, []) as Array[RegionIcon]
		for r in faction_regions:
			r.self_modulate = Color(0, 0, 1, 1)
		highlighted_regions.append_array(faction_regions)

		factions_turn_ui.set_faction(FactionsState.FACTIONS_TEXT.get(faction, "This is a bug"))

		if not factions_turn_ui.visible:
			factions_turn_ui.show()
