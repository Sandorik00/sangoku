# plugin.gd
@tool
extends EditorPlugin

func _enter_tree():
	var script = preload("res://addons/San's Grid/entry.gd")
	#var icon = preload("res://addons/my_custom_nodes/icon.svg")

	add_custom_type("SanGrid", "Node2D", script, null)

func _exit_tree():
	remove_custom_type("SanGrid")
