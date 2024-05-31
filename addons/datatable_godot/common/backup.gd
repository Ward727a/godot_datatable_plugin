@tool
extends _dt_common
class_name _dt_backup

static var _INSTANCE: _dt_backup = null

var _folder: String
var _max: int

static func get_instance() -> _dt_backup:
	
	if _INSTANCE:
		return _INSTANCE
	
	_INSTANCE = _dt_backup.new()
	return _INSTANCE


# Init

func _init():
	
	var config = _dt_plugin.get_instance()
	
	_folder = config.get_backup_path()
	_max = int(config.get_backup_max())


# Backend

func get_path():
	return _folder

func get_max():
	return _max

