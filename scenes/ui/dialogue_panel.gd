class_name DialoguePanel
extends CanvasLayer

signal finished

const CHARS_PER_SECOND := 45.0

@onready var background: TextureRect = %Background
@onready var portrait: TextureRect = %Portrait
@onready var speaker_name: Label = %SpeakerName
@onready var text_label: RichTextLabel = %Text
@onready var arrow: Label = %Arrow

var _lines: Array = []
var _speakers: Dictionary = {}
var _index := -1
var _typing := false
var _tween: Tween


func start(data: Dictionary, speakers: Dictionary) -> void:
	_speakers = speakers
	_lines = data.get("lines", [])
	_index = -1
	arrow.hide()

	var bg_path := String(data.get("background", ""))
	if bg_path != "" and ResourceLoader.exists(bg_path):
		background.texture = load(bg_path) as Texture2D
		background.show()
	else:
		background.texture = null
		background.hide()

	visible = true
	if _lines.is_empty():
		_close()
		return
	_next()


func _next() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return

	var line: Dictionary = _lines[_index]
	var speaker: Dictionary = _speakers.get(String(line.get("who", "")), {})

	var name_key := String(speaker.get("name_key", ""))
	speaker_name.text = tr(name_key) if name_key != "" else ""
	speaker_name.visible = name_key != ""

	var portrait_path := String(speaker.get("portrait", ""))
	portrait.texture = null
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path) as Texture2D

	var key := String(line.get("key", ""))
	var text := tr(key)
	if text == key:
		text = "[color=#ffd166]⟦%s⟧[/color]" % key
	text_label.text = text
	_type_text()


func _type_text() -> void:
	text_label.visible_characters = 0
	arrow.hide()
	if _tween:
		_tween.kill()

	var total := text_label.get_total_character_count()
	_typing = total > 0
	if not _typing:
		arrow.show()
		return

	_tween = create_tween()
	_tween.tween_property(text_label, "visible_characters", total, maxf(0.05, float(total) / CHARS_PER_SECOND))
	_tween.finished.connect(_on_typing_done)


func _on_typing_done() -> void:
	_typing = false
	text_label.visible_characters = -1
	arrow.show()


func _close() -> void:
	if _tween:
		_tween.kill()
	_typing = false
	visible = false
	finished.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	var advance := event.is_action_pressed("ui_accept")
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if not advance:
		return

	get_viewport().set_input_as_handled()
	if _typing:
		if _tween:
			_tween.kill()
		_on_typing_done()
	else:
		_next()
