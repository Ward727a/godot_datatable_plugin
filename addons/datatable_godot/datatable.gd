@tool
extends EditorPlugin

var datatableDock: Node

@onready var common: Node

const tab_icon = preload("res://addons/datatable_godot/icons/tab_icon.svg")


var editor_window: Window

func _enter_tree():
	# Initialization of the plugin goes here.
	datatableDock = preload("res://addons/datatable_godot/datatable.tscn").instantiate()
	
	_add_data_table_dock()
	datatableDock.hide()
	
	common = datatableDock.get_node('signals')
	
	common.toggle_plugin_on.emit()
	
	print("[DataTable] => Plugin is enabled!")
	
	add_autoload_singleton("datatable", "res://addons/datatable_godot/singleton.gd")

func _exit_tree():
	common.toggle_plugin_off.emit()
	
	# Clean-up of the plugin goes here.
	_remove_data_table_dock()
	
	remove_autoload_singleton("datatable")
	
	print("[DataTable] => Plugin is disabled!")
	pass

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Datatable"

func _get_plugin_icon():
	return tab_icon

func _make_visible(visible):
	if is_instance_valid(datatableDock):
		datatableDock.visible = visible

func _add_data_table_dock():
	get_editor_interface().get_editor_main_screen().add_child(datatableDock)

func _remove_data_table_dock():
	datatableDock.queue_free()
