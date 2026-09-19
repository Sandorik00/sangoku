extends Control
class_name PreparationPanel

signal unit_for_placement_changed(id: int)
signal unit_was_placed(replaced_unit_id: int)
signal unit_remove(id: int)

@export var units_card_container: HBoxContainer
@export var preparation_unit_card_ps: PackedScene
@export var start_combat_btn: Button

var unit_cards: Dictionary[int, PreparationUnitCard] = {}
var ids_to_unit_cards: Dictionary[int, PreparationUnitCard] = {}
var last_highlighted_index: int = -1

func create_unit_cards(entities: Dictionary[int, SanGrid.GridEntity]) -> Dictionary[int, PreparationUnitCard]:
	for child in units_card_container.get_children(): child.queue_free()
	unit_cards.clear()
	ids_to_unit_cards.clear()

	for i in entities.keys():
		var preparation_unit_card: PreparationUnitCard = preparation_unit_card_ps.instantiate()
		preparation_unit_card.unit_entity = entities.get(i)
		preparation_unit_card.prepare()

		preparation_unit_card.btn.gui_input.connect(_on_unit_card_pressed.bind(i))
		unit_cards.set(i, preparation_unit_card)
		units_card_container.add_child(preparation_unit_card)

	unit_was_placed.connect(_on_unit_was_placed)

	for card: PreparationUnitCard in unit_cards.values():
		ids_to_unit_cards.set(card.unit_entity.id, card)

	return ids_to_unit_cards

func _on_unit_card_pressed(event: InputEvent, index: int):
	if event is InputEventMouseButton && event.is_released():
		var last_highlighted_card: PreparationUnitCard = unit_cards.get(last_highlighted_index)
		if last_highlighted_card: last_highlighted_card.blur()

		var card: PreparationUnitCard = unit_cards.get(index)

		match event.button_index:
			MOUSE_BUTTON_LEFT:
				card.highlight()
				last_highlighted_index = index
				
				unit_for_placement_changed.emit(card.unit_entity.id)
			MOUSE_BUTTON_RIGHT:
				last_highlighted_index = -1
				unit_for_placement_changed.emit(-1)

				card.undim()
				unit_remove.emit(card.unit_entity.id)

func _on_unit_was_placed(replaced_unit_id: int):
	var last_highlighted_card: PreparationUnitCard = unit_cards.get(last_highlighted_index)
	if last_highlighted_card:
		last_highlighted_card.blur()
		last_highlighted_card.dim()

	if replaced_unit_id:
		var replaced_unit_card = ids_to_unit_cards.get(replaced_unit_id)
		(replaced_unit_card as PreparationUnitCard).undim()

	last_highlighted_index = -1
	unit_for_placement_changed.emit(-1)
