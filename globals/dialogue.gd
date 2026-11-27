extends Node

const SCENES_DIR := "res://dialogue/scenes/"
const SPEAKERS_PATH := "res://dialogue/speakers.json"
const PANEL_SCENE := preload("res://scenes/ui/dialogue_panel.tscn")

const AUTOSTART_SCENE := "test_intro"

signal started(scene_id: String)
signal finished(scene_id: String)

var pause_game := true

var _panel: Node
var _speakers: Dictionary = {}
var _queue: Array[String] = []
var _playing := false
var _was_paused := false


func _ready() -> void:
	if AUTOSTART_SCENE != "":
		_autostart.call_deferred()


func _autostart() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	play(AUTOSTART_SCENE)


## Plays a dialogue scene by id (file name without .json)
func play(scene_id: String) -> void:
	if _playing:
		_queue.append(scene_id)
		return

	var data := _load_json(SCENES_DIR + scene_id + ".json")
	if data.is_empty():
		push_error("Dialogue: scene '%s' is missing or invalid" % scene_id)
		return

	_playing = true
	print_verbose("Dialogue: playing '%s'" % scene_id)
	_was_paused = get_tree().paused
	if pause_game:
		get_tree().paused = true

	var panel := _get_panel()
	panel.start(data, _get_speakers())
	started.emit(scene_id)
	await panel.finished

	if pause_game:
		get_tree().paused = _was_paused
	_playing = false
	finished.emit(scene_id)

	if not _queue.is_empty():
		play(_queue.pop_front())


func is_playing() -> bool:
	return _playing


func _get_panel() -> Node:
	if _panel == null:
		_panel = PANEL_SCENE.instantiate()
		get_tree().root.add_child(_panel)
	return _panel


func _get_speakers() -> Dictionary:
	if _speakers.is_empty():
		_speakers = _load_json(SPEAKERS_PATH)
	return _speakers


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Dialogue: invalid JSON in %s" % path)
		return {}
	return parsed
