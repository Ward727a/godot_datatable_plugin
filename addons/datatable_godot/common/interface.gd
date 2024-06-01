@tool
extends _dt_common
class_name _dt_interface

## Class that manage all the interface system of the plugin

const check_update_text: String = "[img]res://addons/datatable_godot/icons/Reload.png[/img] Checking for update... "
const up_to_date_text: String = "[img]res://addons/datatable_godot/icons/StatusSuccess.png[/img] [color=lightgreen]Version up-to-date! "
const update_available_text: String = "[img]res://addons/datatable_godot/icons/StatusError.png[/img] [color=#ff768b]An update is available! "
const cant_check_text: String = "[img]res://addons/datatable_godot/icons/StatusWarning.png[/img] [color=ffde66]Couldn't check for update! "

const check_update_tip: String = "The plugin is check for an update..."
const up_to_date_tip: String = "You good to go, you got the last version available!"
const update_available_tip: String = "A new update is available, please update it!"
const cant_check_tip: String = "The plugin couldn't check if an update was available due to an unknown error. Check it manually please!"

var _main: Control


static var _INSTANCE: _dt_interface

static func delete():
	_INSTANCE = null


static func get_instance() -> _dt_interface:
	
	if !_INSTANCE || _dt_plugin.get_instance().get_dev_reset_instance() == "true":
		_INSTANCE = _dt_interface.new()
	
	_INSTANCE.load_var()
	return _INSTANCE

# Init

func load_var():
	# can be used to init variable if needed
	pass

# Backend

func set_main(value: Control):
	_main = value

func get_main() -> Control:
	
	if !_main:
		ASSERT_ERROR("Can't get main interface because it's null, it need to be initiated by the main plugin script")
		return null
	
	return _main

func show_main():
	get_main().toggleMain()

func show_type():
	get_main().toggleManageType()

func show_table():
	get_main().toggleNewTable()
