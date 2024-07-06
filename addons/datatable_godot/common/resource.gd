@tool
extends _dt_common
class_name _dt_resource

## Class that manages all the save / load datatable collection file

const _collection_required_key = ["table", "type"]

signal res_saved(path: String)
signal res_loaded(path: String)
signal res_created(path: String)
signal res_reload

var table_datas: Dictionary
var table_types: Dictionary
var table_meta: Dictionary

var _loaded_path: String
var _collection_path: String
var _collection_name: String

var _ext: String
var _version: String

static var _INSTANCE: _dt_resource

static func delete():
	_INSTANCE.DEBUG("Delete resource instance")
	_INSTANCE = null


static func get_instance() -> _dt_resource:
	
	if !_INSTANCE || _dt_plugin.get_instance().get_dev_reset_instance() == "true":
		_INSTANCE = _dt_resource.new()
	
	_INSTANCE.DEBUG("Getting resource instance")
	
	_INSTANCE.load_var()
	return _INSTANCE

# Init

func load_var():
	
	_ext = _dt_plugin.get_instance().get_file_ext()
	_version = _dt_plugin.get_instance().get_file_version()

# public

func set_name(path_or_name: String):
	DEBUG(str("Set name of resource: ", path_or_name))
	if path_or_name.contains(".res"):
		_collection_name = _get_file_name(path_or_name)
	else:
		_collection_name = path_or_name

func set_path(path: String):
	DEBUG(str("Set path of resource: ", path))
	_collection_path = path
	set_name(path)

func get_path():
	return _collection_path

func get_name():
	return _collection_name

func get_data() -> Dictionary:
	
	return table_datas

func get_type() -> Dictionary:
	
	return table_types

func get_metas() -> Dictionary:
	
	return table_meta

func set_data(packedData: PackedDataContainer):
	
	table_datas.clear()
	
	var table_data = packedData['table']
	
	for main_key in table_data:
		
		var data = table_data[main_key]
		
		table_datas[main_key] = {"name": data['name'], "size": data['size'], "structure": data['structure'], "rows": {}}
		
		for row_key in data['rows']:
			
			var row_data = data['rows'][row_key] # name, columns
			
			table_datas[main_key]['rows'][row_key] = {"name": row_data['name'], "columns": {}}
			
			for column_key in row_data['columns']:
				
				var column_data = row_data['columns'][column_key] # name, value, type
				
				table_datas[main_key]['rows'][row_key]['columns'][column_key] = {}

				for i in column_data:
					match(i):
						"name":
							table_datas[main_key]['rows'][row_key]['columns'][column_key]['name'] = column_data['name']
						"value":
							# We check if it's a dictionary, if it's the case we need to convert it from a packedDataContainer to a dictionary
							if column_data['value'] is PackedDataContainerRef:
								var packDataRef = column_data['value']
								var packDataValue = packedData_to_dict(packDataRef)
								table_datas[main_key]['rows'][row_key]['columns'][column_key]['value'] = packDataValue
							else:
								table_datas[main_key]['rows'][row_key]['columns'][column_key]['value'] = column_data['value']
						"type":
							table_datas[main_key]['rows'][row_key]['columns'][column_key]['type'] = column_data['type']
						"size":
							table_datas[main_key]['rows'][row_key]['columns'][column_key]['size'] = column_data['size']
						_:
							push_error("[DataTable] Loading a collection, but found an unknown key: ", i, " by security this key will be kept, but if it's not wanted inform the developper!")
							table_datas[main_key]['rows'][row_key]['columns'][column_key][i] = column_data[i]

func packedData_to_dict(packedData: Variant, _watch_dog: int = 0) -> Dictionary:
	
	var watch_dog = _watch_dog

	var dic = {}

	for packed_key in packedData:

		if watch_dog > 1000:
			push_error("[DataTable] The watch dog has been triggered, the loop has been stopped to avoid an infinite loop!")
			break

		watch_dog += 1

		dic[packed_key] = packedData[packed_key]

		if dic[packed_key] is PackedDataContainerRef:
			dic[packed_key] = packedData_to_dict(dic[packed_key], watch_dog)

	return dic

func set_type(packedData: PackedDataContainer):
	
	table_types.clear()
	
	var type_data = packedData['type']
	
	for main_key in type_data: # name of type
		
		var type = type_data[main_key]
		
		table_types[main_key] = {"name": type['name'], "params":{}}
		
		for param_key in type['params']:
			
			var param = type["params"][param_key]
			
			table_types[main_key]["params"][param_key] = {"name":"", "type": 0, "size": 0, "comment": "", "default": ""}
			
			for i in param:
				match(i):
					"name":
						table_types[main_key]["params"][param_key]["name"] = param['name']
					"type":
						table_types[main_key]["params"][param_key]["type"] = param['type']
					"size":
						table_types[main_key]["params"][param_key]["size"] = param['size']
					"comment":
						table_types[main_key]["params"][param_key]["comment"] = param['comment']
					"default":
						table_types[main_key]["params"][param_key]["default"] = param['default']
					_:
						push_error("[DataTable] Loading a collection, but found an unknown key: ", i, " by security this key will be kept, but if it's not wanted inform the developper!")
						table_types[main_key]["params"][param_key][i] = param[i]

func set_metas(packedData: PackedDataContainer):
	
	table_meta.clear()

	if packedData.size() == 2:
		table_meta = {"version": "1.0.0"}
		return
	
	var meta_data = packedData['meta']
	
	table_meta["version"] = meta_data['version']

func force_load(path: String = "") -> Dictionary:
	
	var save_path = path
	
	if path.is_empty():
		save_path = get_path()
	else:
		set_path(path)
	
	if !_check_path(save_path):
		ASSERT_ERROR(str("The file '",save_path,"' doesn't exist!"))
		return {}
	
	if !_is_valid_resource_file(save_path):
		ERROR(str("The file '",save_path,"' is not a valid collection file!"))
		return {}
	
	var packedData = load(save_path)
	
	set_data(packedData)
	set_type(packedData)
	set_metas(packedData)
	
	_loaded_path = save_path
	
	var dic = {"table": get_data(), "type": get_type(), "meta": get_metas()}

	return dic

func load_file(path: String = "") -> Dictionary:
	
	var save_path = path
	
	if path.is_empty():
		save_path = get_path()
	else:
		set_path(path)
	
	if !_check_path(save_path):
		ASSERT_ERROR(str("The file '",save_path,"' doesn't exist!"))
		return {}
	
	if !_is_valid_resource_file(save_path):
		ERROR(str("The file '",save_path,"' is not a valid collection file!"))
		return {}
	
	if _loaded_path == save_path:
		var dic = {"table": get_data(), "type": get_type(), "meta": get_metas()}
		return dic
	
	var packedData = load(save_path)
	
	set_data(packedData)
	set_type(packedData)
	set_metas(packedData)
	
	res_loaded.emit(_collection_path)
	_loaded_path = save_path
	
	var dic = {"table": get_data(), "type": get_type(), "meta": get_metas()}

	_dt_compatibility.get_instance().check_compatibility(dic)

	return dic

func save_file():
	if _collection_path.is_empty():
		return
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var datas = {"table": table_datas, "type": table_types, "meta": table_meta}

	packedData.pack(datas)
	
	ResourceSaver.save(packedData, _collection_path)
	res_saved.emit(_collection_path)

func manualy_save_file(path: String, datas: Dictionary) -> bool:

	if path.is_empty():
		ERROR("Can't save a file with an empty given path")
		return false
	
	if datas == null:
		ERROR("Can't save a file with a null given datas")
		return false

	if datas.size() == 0:
		ERROR("Can't save a file with an empty given datas")
		return false
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	packedData.pack(datas)
	
	ResourceSaver.save(packedData, path)
	res_saved.emit(path)
	return true

func new_file(path: String) -> bool:
	if path.is_empty():
		ERROR("Can't create a new file with an empty given path")
		return false
	
	var _file_name = _get_file_name(path)
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	packedData.pack({"table": {}, "type": {}, "meta": {"version": _dt_plugin.get_instance().get_file_version()}})
	
	var ret = ResourceSaver.save(packedData, path)
	
	if ret != OK:
		ERROR("Can't save collection due to an error when trying to save it!")
		return false
	
	set_data(packedData)
	set_type(packedData)
	
	set_path(path)
	
	res_created.emit(path)
	
	return true

# private

func _check_path(path: String) -> bool:
	
	if path == null || path.is_empty():
		return false
	
	if !ResourceLoader.exists(path):
		return false
	
	return true

func _get_file_name(path: String) -> String:
	var collections_name
	
	if path.ends_with(_ext):
		collections_name = path.split(_ext)[0].split("/")
	else:
		collections_name = path.split(".res")[0].split("/")
	
	var collection_name = collections_name[collections_name.size()-1]
	
	return collection_name

func _is_valid_resource_file(path: String) -> bool:
	
	var res = load(path)
	
	if res.get_class() != "PackedDataContainer":
		ERROR("This file isn't a PackedDataContainer!")
		return false
	
	var key_index = 0
	
	for i in res:
		if _collection_required_key.has(i):
			key_index += 1
	
	if key_index != _collection_required_key.size():
		ERROR("This file doesn't have the required key to be an valid collection!")
		return false
	
	return true
