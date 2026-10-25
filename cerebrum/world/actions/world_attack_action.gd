extends WorldBTNode
class_name WorldAttackAction

func evaluate(faction: FactionData, _context: Dictionary) -> float:
	# var army_strength_ratio = faction.army_power / max(1.0, context.weakest_neighbor_power)
	# var base_score = clamp(army_strength_ratio - 0.5, 0.0, 1.5)

	var base_score = 0.5
	
	var final_score = base_score * faction.evilness
	
	if faction.army_power < 100:
		final_score *= 0.1
	elif faction.army_power > 5000:
		final_score *= 1.3
		
	return final_score

func execute(faction: FactionData, context: Dictionary) -> void:
	var UI: GlobalUI = context.get("UI")

	print(FactionsState.FACTIONS_TEXT.get(faction.faction) + " is attacking...")

	var current_provinces: Array[Province] = []
	var available_provinces: Dictionary[int, Province] = {}
	var available_regions: Array[Region] = []
	var weakest_neighbor_regions: Array[Region] = []

	for province: Province in WorldState.ALL_PROVINCES.values():
		if province.faction == faction.faction: current_provinces.push_back(province)

	for province: Province in current_provinces:
		for province_id in province.neighbors:
			available_provinces.set(province_id, WorldState.ALL_PROVINCES.get(province_id))

	var power_benchmark := faction.army_power + (faction.army_power * 0.3)

	for province: Province in available_provinces.values():
		for reg_id in province.regions:
			var reg: Region = WorldState.ALL_REGIONS.get(reg_id)
			if reg.faction != faction.faction:
				available_regions.push_back(reg)

	for reg in available_regions:
		var region_faction_data: FactionData = WorldState.FACTIONS_TO_DATA.get(reg.faction)

		#  && region_faction_data.faction != FactionsState.FACTIONS.RAVINE_HUMANS
		if region_faction_data.army_power < power_benchmark && region_faction_data.faction != FactionsState.FACTIONS.RAVINE_HUMANS:
			weakest_neighbor_regions.push_back(reg)

	if weakest_neighbor_regions.is_empty():
		print("Nothing to attack!")
		return

	var random_index := int(Grng.RNG.randi() % weakest_neighbor_regions.size())
	var region_to_attack: Region = weakest_neighbor_regions.get(random_index)

	# UI shenanigans
	var available_regions_ids: Array = available_regions.map(func(r: Region): return r.id)
	var available_region_icons = WorldState.ALL_REGION_ICONS.values().filter(func(ri: RegionIcon): return ri.res.id in available_regions_ids)
	UI.highlight_available_regions(available_region_icons)

	UI.highlight_region(WorldState.ALL_REGION_ICONS.get(region_to_attack.id), Color(1, 0, 0, 1))
	
	WorldTurnLogic.initiate_combat(faction.faction, region_to_attack.faction, region_to_attack)
