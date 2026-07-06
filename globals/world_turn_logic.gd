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
var _campaign_factions: Array[FactionsState.FACTIONS] = [
	FactionsState.FACTIONS.SAN,
	FactionsState.FACTIONS.ROMBUS,
	FactionsState.FACTIONS.RIK,
]
var _current_faction: FactionsState.FACTIONS = _campaign_factions.get(_index)

var cerebrum: WorldBTSelector

func _ready():
	turn_end.connect(_on_turn_end)

	cerebrum = WorldBTSelector.new([
		WorldAttackAction.new(),
		WorldChillAction.new(),
	])

func _on_turn_end():
	_index = wrapi(_index + 1, 0, _campaign_factions.size())

	_transfer_control(_campaign_factions.get(_index))

func _transfer_control(faction: FactionsState.FACTIONS):
	if _current_faction == FactionsState.FACTIONS.SAN:
		global_ui.modulate = Color(1, 1, 1, 0.5)
		global_ui.process_mode = Node.PROCESS_MODE_DISABLED

	_current_faction = faction

	global_ui.toggle_on_turn_end(_current_faction == FactionsState.FACTIONS.SAN, _current_faction)

	if _current_faction == FactionsState.FACTIONS.SAN:
		global_ui.modulate = Color(1, 1, 1, 1)
		global_ui.process_mode = Node.PROCESS_MODE_INHERIT
	else: _do_cerebrum_things()

func _do_cerebrum_things():
	await get_tree().create_timer(2.0).timeout

	cerebrum.make_decision(WorldState.FACTIONS_TO_DATA.get(_current_faction), {})

	turn_end.emit()

# common actions
func into_combat():
	world.hide()
	global_ui.hide()

	combat = combat_ps.instantiate()
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
