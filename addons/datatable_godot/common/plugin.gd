@tool
extends _dt_common
class_name _dt_plugin

## Class that manage all the config, and plugin related information for the plugin

const LOCAL_PATH: String = "res://addons/datatable_godot/"
const LOCAL_CONFIG_PATH: String = "res://addons/datatable_godot/plugin.cfg"

var _config: ConfigFile

static var _INSTANCE: _dt_plugin = null

static func get_instance() -> _dt_plugin:
	
	if _INSTANCE:
		return _INSTANCE
	
	_INSTANCE = _dt_plugin.new()
	return _INSTANCE

# Init

func _init():
	_config = ConfigFile.new()
	_config.load(LOCAL_CONFIG_PATH)

# Config

func get_version() -> String:
	return _config.get_value("plugin", "version")

func get_name() -> String:
	return _config.get_value("plugin", "name")

func get_file_version() -> String:
	return _config.get_value("file", "version")

func get_file_ext() -> String:
	return _config.get_value("file", "ext")

func get_backup_path() -> String:
	return _config.get_value("backup", "folder")

func get_backup_max() -> String:
	return _config.get_value("backup", "max")

func get_backup_suffix() -> String:
	return _config.get_value("backup", "suffix")

# Convert a version number to an actually comparable number
# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func version_to_number(version: String) -> int:
	
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()
