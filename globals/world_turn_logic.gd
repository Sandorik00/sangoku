extends Node

signal turn_end()

@onready var global_ui: GlobalUI = $/root/Main/CanvasLayer/UI

@onready var combat_ui: Control = $/root/Main/CanvasLayer/CombatUI
@onready var command_panel: CommandPanel = $/root/Main/CanvasLayer/CommandPanel
@onready var world: Node2D = $/root/Main/CanvasLayer/World
@onready var world_camera: Camera2D = $/root/Main/CanvasLayer/WorldCamera
@onready var sub_viewport: SubViewport = $/root/Main/CanvasLayer/SubViewportContainer/SubViewport

var combat_ps: PackedScene = preload("uid://dxyjbs03ln8sa")
var combat: Combat = null

var _index = 0
var _campaign_factions: Array[FactionsState.FACTIONS] = []

var _current_faction: FactionsState.FACTIONS = WorldState.player_faction

var cerebrum: WorldBTSelector

func _ready():
	var unsorted_factions = FactionsState.FACTIONS.values().duplicate()
	unsorted_factions.sort_custom(func(f1, _f2): return f1 == WorldState.player_faction)

	_campaign_factions.assign(unsorted_factions)

	turn_end.connect(_on_turn_end)

	cerebrum = WorldBTSelector.new([
		WorldAttackAction.new(),
		WorldChillAction.new(),
	])

func _on_turn_end():
	_index = wrapi(_index + 1, 0, _campaign_factions.size())

	_transfer_control(_campaign_factions.get(_index))

func _transfer_control(faction: FactionsState.FACTIONS):
	if _current_faction == WorldState.player_faction:
		global_ui.modulate = Color(1, 1, 1, 0.5)
		global_ui.process_mode = Node.PROCESS_MODE_DISABLED

	_current_faction = faction

	global_ui.toggle_on_turn_end(_current_faction == WorldState.player_faction, _current_faction)

	# turn start
	_setup_turn()
	WorldState.player_data_changed.emit()

	if _current_faction == WorldState.player_faction:
		global_ui.modulate = Color(1, 1, 1, 1)
		global_ui.process_mode = Node.PROCESS_MODE_INHERIT
	else: _do_cerebrum_things()

func _do_cerebrum_things():
	await get_tree().create_timer(0.5).timeout

	cerebrum.make_decision(WorldState.FACTIONS_TO_DATA.get(_current_faction), {})

	turn_end.emit()

# common actions
func into_combat():
	world.hide()
	global_ui.hide()

	combat = combat_ps.instantiate()
	# TODO: fix here also!
	combat.setup_combat_entities(WorldState.PLAYER_UNITS.values() + WorldState.DEFAULT_ENEMY_UNITS.values())

	sub_viewport.add_child(combat)

	world_camera.enabled = false

func out_combat():
	CombatData.clear_units_ui()
	command_panel.hide()
	world.show()
	global_ui.show()
	world_camera.enabled = true

	combat.queue_free()
	combat = null

func _setup_turn():
	_calc_income()

func _calc_income():
	var faction_data: FactionData = WorldState.FACTIONS_TO_DATA.get(_current_faction)
	var income = 0

	for r: Region in WorldState.ALL_REGIONS.values():
		if r.faction == _current_faction:
			income += Types.BASE_INCOME * r.rank

	faction_data.money += income
