extends SceneTree

## Checks that every key used by dialogue scenes exists in the CSV translation.
##
## Run from the project folder:
##   godot --headless --script res://dialogue/validate_dialogue.gd
##
## Exit code 0 = OK, 1 = errors found.

const DIALOGUE_DIR := "res://dialogue"
const SCENES_DIR := DIALOGUE_DIR + "/scenes"
const SPEAKERS_PATH := DIALOGUE_DIR + "/speakers.json"
const CSV_PATH := "res://localization/dialogue.csv"

var _errors := 0
var _warnings := 0


func _init() -> void:
	print("=== Dialogue validation ===")

	var csv := _read_csv()
	var locales: PackedStringArray = csv["locales"]
	var rows: Dictionary = csv["rows"]

	var used := _collect_used_keys()

	for key: String in used:
		if not rows.has(key):
			_error("key '%s' is missing from %s  (%s)" % [key, CSV_PATH, ", ".join(PackedStringArray(used[key]))])
			continue
		var texts: Dictionary = rows[key]
		for locale in locales:
			if String(texts.get(locale, "")).strip_edges() == "":
				_warning("key '%s' has empty '%s' text" % [key, locale])

	for key: String in rows:
		if not used.has(key):
			_warning("key '%s' is never used" % key)

	print("locales: %s | csv keys: %d | used keys: %d" % [", ".join(locales), rows.size(), used.size()])

	if _errors > 0:
		printerr("FAILED: %d error(s), %d warning(s)" % [_errors, _warnings])
		quit(1)
	else:
		print("OK: 0 errors, %d warning(s)" % _warnings)
		quit(0)


func _read_csv() -> Dictionary:
	var locales := PackedStringArray()
	var rows := {}

	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		_error("cannot open %s" % CSV_PATH)
		return { "locales": locales, "rows": rows }

	var header := file.get_csv_line()
	var columns := {}
	for i in range(1, header.size()):
		var column := header[i].strip_edges()
		if column == "" or column.begins_with("?") or column.begins_with("_"):
			continue
		columns[column] = i
		locales.append(column)

	if columns.is_empty():
		_error("CSV has no locale columns")
		return { "locales": locales, "rows": rows }

	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty() or row[0].strip_edges() == "":
			continue
		var key := row[0].strip_edges()
		if rows.has(key):
			_error("duplicate key '%s' in CSV" % key)
			continue
		var texts := {}
		for locale: String in columns:
			var index: int = columns[locale]
			texts[locale] = row[index] if index < row.size() else ""
		rows[key] = texts

	return { "locales": locales, "rows": rows }


func _collect_used_keys() -> Dictionary:
	var used := {}

	var speakers := _read_json(SPEAKERS_PATH)
	for speaker_id: String in speakers:
		var speaker: Dictionary = speakers[speaker_id]
		var name_key := String(speaker.get("name_key", ""))
		if name_key != "":
			_add_use(used, name_key, "speakers.json:%s" % speaker_id)
		var portrait := String(speaker.get("portrait", ""))
		if portrait != "" and not FileAccess.file_exists(portrait):
			_error("speakers.json:%s — portrait not found: %s" % [speaker_id, portrait])

	var dir := DirAccess.open(SCENES_DIR)
	if dir == null:
		_error("cannot open %s" % SCENES_DIR)
		return used

	for file_name in dir.get_files():
		if not file_name.ends_with(".json"):
			continue
		var scene := _read_json(SCENES_DIR + "/" + file_name)
		if scene.is_empty():
			continue

		var background := String(scene.get("background", ""))
		if background != "" and not FileAccess.file_exists(background):
			_error("%s — background not found: %s" % [file_name, background])

		var lines: Array = scene.get("lines", [])
		if lines.is_empty():
			_warning("%s has no lines" % file_name)
		for i in lines.size():
			var line: Dictionary = lines[i]
			var where := "%s:%d" % [file_name, i + 1]

			var key := String(line.get("key", ""))
			if key == "":
				_error("%s — line has no 'key'" % where)
			else:
				_add_use(used, key, where)

			var who := String(line.get("who", ""))
			if who != "" and not speakers.has(who):
				_error("%s — unknown speaker '%s'" % [where, who])

	return used


func _add_use(used: Dictionary, key: String, where: String) -> void:
	if not used.has(key):
		used[key] = []
	used[key].append(where)


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_error("file not found: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		_error("invalid JSON: %s" % path)
		return {}
	return parsed


func _error(message: String) -> void:
	_errors += 1
	printerr("ERROR: " + message)


func _warning(message: String) -> void:
	_warnings += 1
	print("WARN:  " + message)
