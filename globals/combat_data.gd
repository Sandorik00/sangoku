extends Node

signal unit_data_changed(unit: Unit)

@onready var combat_ui: Control = $/root/Main/CanvasLayer/CombatUI
@onready var sub_viewport_container: SubViewportContainer = $/root/Main/CanvasLayer/SubViewportContainer
@onready var army_count_label: PackedScene = preload("res://scenes/ui/army_count.tscn")

@onready var sub_viewport_transform: Transform2D = sub_viewport_container.get_global_transform()

var panel_unit_data: Unit :
	set(new_value):
		panel_unit_data = new_value
		unit_data_changed.emit(new_value)

var unitsInCombat: Dictionary[int, Unit] = {}

var moving_unit: SanGrid.GridEntity = null
var moving_label: Label = null
var units_by_labels: Dictionary[int, Label]

func add_units_ui(unit_entities_in_combat: Array[SanGrid.GridEntity]):
	for ue in unit_entities_in_combat:
		var acl = army_count_label.instantiate() as Label

		var local_in_viewport = ue.unitNode.get_global_transform_with_canvas()
		var result_transform = sub_viewport_transform * local_in_viewport.origin

		acl.global_position = ((result_transform + Vector2(-16, 8)) * 3)
		acl.text = str(unitsInCombat[ue.id].troops)
		units_by_labels.set(ue.id, acl)
		combat_ui.add_child(acl)

func move_unit_label(unit: SanGrid.GridEntity):
	moving_unit = unit
	moving_label = units_by_labels[unit.id]

func reset_moving_label():
	moving_unit = null
	moving_label = null
