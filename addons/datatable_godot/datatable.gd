@tool
extends EditorPlugin

var datatableDock: Node

@onready var common: Node

const tab_icon = preload("res://addons/datatable_godot/icons/tab_icon.svg")
const tab_path = "res://addons/datatable_godot/datatable.tscn"

func _enter_tree():
	# Initialization of the plugin goes here.
	datatableDock = preload(tab_path).instantiate()
	
	_add_data_table_dock()
	datatableDock.hide()
	
	common = datatableDock.get_node('signals')
	
	_dt_interface.get_instance().set_main(datatableDock)
	
	print("[DataTable] => Plugin is enabled!")
	
	_dt_plugin.get_instance().plugin_on.emit()

func _exit_tree():
	_dt_plugin.get_instance().plugin_off.emit()
	
	# Clean-up of the plugin goes here.
	_remove_data_table_dock()
	
	print("[DataTable] => Plugin is disabled!")
	
	_dt_plugin.get_instance().delete()
	_dt_interface.get_instance().delete()
	_dt_resource.get_instance().delete()
	_dt_backup.get_instance().delete()
	_dt_updater.get_instance().delete()
	_dt_schema.get_instance().delete()
	_dt_class_generator.get_instance().delete()
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
		if visible:
			datatableDock.check_for_datatable_change()

func _add_data_table_dock():
	get_editor_interface().get_editor_main_screen().add_child(datatableDock)

func _remove_data_table_dock():
	datatableDock.queue_free()
