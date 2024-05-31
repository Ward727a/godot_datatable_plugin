@tool
extends _dt_common
class_name _dt_backup

## Class that manage all the backup system

static var _INSTANCE: _dt_backup = null

var _folder: String
var _max: int
var _suffix: String

var _index: int = 0
var _most_recent_path: String

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
	_suffix = config.get_backup_suffix()

# Backend

func get_path():
	return _folder

func get_max():
	return _max

func make(path: String):
	
	if !_check_path(path):
		return
	
	var data = load(path)
	
	var file_name = _get_file_name(path)
	
	if file_name.is_empty():
		ASSERT_ERROR("File name is empty, cancelling backup")
		return
	
	var index = _get_index(path)
	
	var backup_file_path = str(_folder, "/", file_name, _suffix, index, _dt_plugin.get_instance().get_file_ext())
	
	if !_has_dir():
		return
	
	var err = ResourceSaver.save(data, backup_file_path)
	
	if err != OK:
		ASSERT_ERROR("Couldn't create backup file!")
	else:
		print_rich("[color=lightgreen][DataTable] Created a backup for '",file_name,"' collection, path: ",backup_file_path)

func _get_file_name(path: String)->String:
	
	var file_name
	
	if path.ends_with(".tableCollection.res"):
		var path_splitted = path.split(".tableCollection.res")
		path_splitted = path_splitted[0].split("/")
		file_name = path_splitted[path_splitted.size()-1]
	else:
		var path_splitted = path.split(".res")
		path_splitted = path_splitted[0].split("/")
		file_name = path_splitted[path_splitted.size()-1]
	
	return file_name

func _check_path(path: String)->bool:
	
	if path == null || path.is_empty():
		ASSERT_ERROR("Can't make a backup of an empty path")
		return false
	
	if path.contains(_folder):
		ASSERT_ERROR("Can't make a backup of a backup file")
		return false
	
	return true

func _get_index(path: String)->int:
	
	_index += 1
	
	if _index > _max:
		_index = 1
	
	if _most_recent_path != path:
		_index = 1
	
	_most_recent_path = path
	
	return _index

func _has_dir()->bool:
	var backup_dir = DirAccess.open("res://")
	
	var dir_path = _folder.replace('res://', "")
	
	if !backup_dir.dir_exists(dir_path):
		var make_err = backup_dir.make_dir(dir_path)
		
		if make_err != OK:
			ASSERT_ERROR(str("The plugin couldn't create the '",dir_path,"' folder in the path: 'res://', the back-up system can't work without it!"))
			return false
	
	return true
