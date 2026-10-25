extends Node

signal turn_end()

@onready var global_ui: GlobalUI = $/root/Main/CanvasLayer/UI

@onready var combat_ui: Control = $/root/Main/CanvasLayer/CombatUI
@onready var command_panel: CommandPanel = $/root/Main/CanvasLayer/CommandPanel
@onready var world: Node2D = $/root/Main/CanvasLayer/World
@onready var world_camera: Camera2D = $/root/Main/CanvasLayer/WorldCamera
@onready var sub_viewport: SubViewport = $/root/Main/CanvasLayer/SubViewportContainer/SubViewport
@onready var preparation_panel: PreparationPanel = $/root/Main/CanvasLayer/PreparationPanel

var combat_ps: PackedScene = preload("uid://dxyjbs03ln8sa")
var combat: Combat = null

var month: int = 0
var week: int = 1

var _index = 0
var _campaign_factions: Array[FactionsState.FACTIONS] = [
	FactionsState.FACTIONS.RAVINE_HUMANS,
	FactionsState.FACTIONS.FOREST_DWARFS,
	FactionsState.FACTIONS.CASTLE_HUMANS,
	FactionsState.FACTIONS.DESERT_EMPIRE,
	FactionsState.FACTIONS.NORD_ELVES,
]

var _current_faction: FactionsState.FACTIONS = WorldState.player_faction

var cerebrum: WorldBTSelector

var attacked_region: Region = null
var attacking_faction: FactionsState.FACTIONS = FactionsState.FACTIONS.COAST_DWARFS
var defending_faction: FactionsState.FACTIONS = FactionsState.FACTIONS.COAST_DWARFS

func _ready():
	# var unsorted_factions = FactionsState.FACTIONS.values().duplicate()
	# unsorted_factions.sort_custom(func(f1, _f2): return f1 == WorldState.player_faction)

	# _campaign_factions.assign(unsorted_factions)

	turn_end.connect(_on_turn_end)

	cerebrum = WorldBTSelector.new([
		WorldAttackAction.new(),
		WorldChillAction.new(),
		WorldHireAction.new(),
		WorldRefillAction.new(),
	])

func _on_turn_end():
	_index = wrapi(_index + 1, 0, _campaign_factions.size())

	_transfer_control(_campaign_factions.get(_index))

func _transfer_control(faction: FactionsState.FACTIONS):
	if _current_faction == WorldState.player_faction:
		global_ui.modulate = Color(1, 1, 1, 0.5)
		global_ui.process_mode = Node.PROCESS_MODE_DISABLED

	_current_faction = faction

	global_ui.reset_regions_highlight()
	global_ui.toggle_on_turn_end(_current_faction == WorldState.player_faction, _current_faction)

	# turn start
	_setup_turn()
	WorldState.player_data_changed.emit()

	if _current_faction == WorldState.player_faction:
		week += 1
		if week >= 5:
			for faction_data: FactionData in WorldState.FACTIONS_TO_DATA.values():
				faction_data.hired_this_month = false

			month += 1
			week = 1

		global_ui.modulate = Color(1, 1, 1, 1)
		global_ui.process_mode = Node.PROCESS_MODE_INHERIT
	else: _do_cerebrum_things()

func _do_cerebrum_things():
	await get_tree().create_timer(0.5).timeout

	cerebrum.make_decision(WorldState.FACTIONS_TO_DATA.get(_current_faction), { "UI": global_ui })

	await get_tree().create_timer(1).timeout

	turn_end.emit()

# common actions
func initiate_combat(attacker: FactionsState.FACTIONS, defender: FactionsState.FACTIONS, region: Region = null):
	attacking_faction = attacker
	defending_faction = defender
	attacked_region = region

	var attacker_data: FactionData = WorldState.FACTIONS_TO_DATA.get(attacker)
	var defender_data: FactionData = WorldState.FACTIONS_TO_DATA.get(defender)

	if attacker_data.units.is_empty():
		_after_combat(false)
		return
	
	if defender_data.units.is_empty():
		_after_combat(true)
		return

	if attacker == WorldState.player_faction or defender == WorldState.player_faction:
		into_combat(attacker, defender)
	else: _combat_auto_resolve(attacker, defender)

func into_combat(attacker: FactionsState.FACTIONS, defender: FactionsState.FACTIONS):
	world.hide()
	global_ui.hide()

	combat = combat_ps.instantiate()

	var is_player_attacker = attacker == WorldState.player_faction
	var enemy_data: FactionData = null

	if is_player_attacker:
		enemy_data = WorldState.FACTIONS_TO_DATA.get(defender)
	else: enemy_data = WorldState.FACTIONS_TO_DATA.get(attacker)

	combat.setup_combat_entities(
		WorldState.PLAYER_UNITS.values(),
		enemy_data.units.values(),
		is_player_attacker,
	)

	sub_viewport.add_child(combat)

	world_camera.enabled = false

func out_combat(attacker_is_winner: bool):
	CombatData.clear_units_ui()
	command_panel.hide()
	world.show()
	global_ui.show()
	world_camera.enabled = true

	combat.queue_free()
	combat = null

	_after_combat(attacker_is_winner)

func _combat_auto_resolve(attacker: FactionsState.FACTIONS, defender: FactionsState.FACTIONS):
	var attacker_data: FactionData = WorldState.FACTIONS_TO_DATA.get(attacker)
	var defender_data: FactionData = WorldState.FACTIONS_TO_DATA.get(defender)

	var a_power := attacker_data.army_power
	var d_power := int(defender_data.army_power * 1.1) # defenders advantage

	var attack_win_chance: float = get_win_chance(a_power, d_power)
	var rn: float = Grng.RNG.randf()
	var attacker_is_winner = rn < attack_win_chance

	print_rich("[color=yellow][b]FIGHTO!![/b][/color]")
	print_rich("[color=red][b]Attacker power: %s[/b][/color]" % str(a_power))
	print_rich("[color=blue][b]Defender power: %s[/b][/color]" % str(d_power))
	print_rich("[color=green][b]Win chance: %s%%[/b][/color]" % str(int(attack_win_chance * 100)))
	print_rich("[color=green][b]RN: %s[/b][/color]" % str(int(rn * 100)))
	print_rich("[color=green][b]Win?: %s[/b][/color]" % str(attacker_is_winner))

	_kill_units(attacker_data.units, attacker_data.army_power, attack_win_chance)
	_kill_units(defender_data.units, defender_data.army_power, 1.0 - attack_win_chance)

	_after_combat(attacker_is_winner)

func _after_combat(attacker_is_winner: bool):
	var attacker_data: FactionData = WorldState.FACTIONS_TO_DATA.get(attacking_faction)
	var defender_data: FactionData = WorldState.FACTIONS_TO_DATA.get(defending_faction)

	_revive_units(attacker_data.units)
	_revive_units(defender_data.units)

	attacker_data.recalculate_army_power()
	defender_data.recalculate_army_power()

	print(attacker_data.army_power)
	print(defender_data.army_power)

	if attacked_region != null && attacker_is_winner:
		_assume_region_control(attacked_region, attacking_faction)

# win chance 0.0 to 1.0
func get_win_chance(attacker_power: int, defender_power: int) -> float:
	if attacker_power <= 0 or defender_power <= 0:
		push_error("get_win_chance: силы армий должны быть >= 1")
		return 0.5

	var dominant_chance: float

	# relation
	var r: float = maxf(attacker_power, defender_power) / minf(attacker_power, defender_power)

	if r >= 2.0:
		# autowin
		dominant_chance = 1.0
	elif r >= 1.5:
		# linear from 90% to 100%
		dominant_chance = 0.9 + 0.2 * (r - 1.5)
	else:
		# from 50% r=1, to 90% r=1.5
		var t: float = r - 1.0
		dominant_chance = 0.5 + 0.16 * t + 1.28 * t * t # magic numbers go brrrrrr

	if attacker_power >= defender_power:
		return dominant_chance
	else:
		return 1.0 - dominant_chance

func _revive_units(units: UnitsStateDictionary):
	for unit in units.values():
		if unit.troops <= 0: unit.troops = 1

func _kill_units(units: UnitsStateDictionary, army_power: int, win_chance: float):
	var sorted_units: Array[Unit] = units.get_all_sorted_by_lvl_asc()
	var losing_power: int = min(int(army_power * 0.4), army_power * (minf(1.05 - win_chance, 1.0)))
	var limit_for_one_subtraction: int = int(losing_power / 2.0)

	print("Kill units: ")
	print(army_power)
	print(losing_power)

	var left_unit_index: int = 0
	var right_unit_index: int = sorted_units.size() - 1
	var left_index_direction = 1
	var right_index_direction = -1
	var kill_cycles = 5

	while losing_power > 0 and kill_cycles > 0:
		var weak_unit = sorted_units.get(left_unit_index)
		var to_loose_wk = min(
			weak_unit.troops,
			losing_power / weak_unit.level,
			limit_for_one_subtraction / weak_unit.level,
		)
		weak_unit.troops -= to_loose_wk

		losing_power -= to_loose_wk * weak_unit.level

		if left_unit_index == sorted_units.size() - 1: left_index_direction = -1
		elif left_unit_index == 0: left_index_direction = 1
		left_unit_index = clamp(left_unit_index + left_index_direction, 0, sorted_units.size() - 1)

		var strong_unit = sorted_units.get(right_unit_index)
		var to_loose_sg = min(
			strong_unit.troops,
			losing_power / strong_unit.level,
			limit_for_one_subtraction / strong_unit.level,
		)
		strong_unit.troops -= to_loose_sg

		losing_power -= to_loose_sg * strong_unit.level

		if right_unit_index == 0:
			right_index_direction = 1
			kill_cycles -= 1
		elif right_unit_index == sorted_units.size() - 1:
			right_index_direction = -1
			kill_cycles -= 1
		right_unit_index = clamp(right_unit_index + right_index_direction, 0, sorted_units.size() - 1)

func _assume_region_control(region: Region, faction: FactionsState.FACTIONS):
	region.faction = faction
	
	var all_province_regions: Array[Region] = []
	var property_ownership: Dictionary[FactionsState.FACTIONS, int] = {}

	for region_id in region.province.regions:
		all_province_regions.push_back(WorldState.ALL_REGIONS.get(region_id))

	for reg in all_province_regions:
		var last_count: int = property_ownership.get(reg.faction, 0)
		property_ownership.set(reg.faction, last_count + 1)

	var max_owners: Array = Utils.get_factions_with_max_regions(property_ownership)

	if faction in max_owners:
		region.province.faction = faction
	elif region.province.faction in max_owners:
		region.province.faction = region.province.faction
	else:
		region.province.faction = max_owners.front()

func _setup_turn():
	_calc_income()

func _calc_income():
	var faction_data: FactionData = WorldState.FACTIONS_TO_DATA.get(_current_faction)
	var income = 0

	for r: Region in WorldState.ALL_REGIONS.values():
		if r.faction == _current_faction:
			income += Types.BASE_INCOME * r.rank

	faction_data.money += income
