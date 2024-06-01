@tool
extends _dt_common
class_name _dt_resource

## Class that manage all the save / load datatable collection file

signal res_saved(path: String)
signal res_loaded(path: String)
signal res_reload

static var _INSTANCE: _dt_resource = null

var table_datas: Dictionary
var table_types: Dictionary

var _loaded_path: String
var _collection_path: String

static func get_instance() -> _dt_resource:
	
	if _INSTANCE:
		return _INSTANCE
	
	_INSTANCE = _dt_resource.new()
	return _INSTANCE

# public

func set_path(path: String):
	_collection_path = path

func get_path():
	return _collection_path

func get_data() -> Dictionary:
	
	return table_datas

func get_type() -> Dictionary:
	
	return table_types

func set_data(packedData: PackedDataContainer):
	var table_data = packedData['table']
	
	for main_key in table_data:
		
		var data = table_data[main_key]
		
		table_datas[main_key] = {"name": data['name'], "size": data['size'], "structure": data['structure'], "rows": {}}
		
		for row_key in data['rows']:
			
			var row_data = data['rows'][row_key] # name, columns
			
			table_datas[main_key]['rows'][row_key] = {"name": row_data['name'], "columns": {}}
			
			for column_key in row_data['columns']:
				
				var column_data = row_data['columns'][column_key] # name, value, type
				
				table_datas[main_key]['rows'][row_key]['columns'][column_key] = {"name": column_data['name'], "value": column_data['value'], "type": column_data['type'], "size": column_data['size']}

func set_type(packedData: PackedDataContainer):
	var type_data = packedData['type']
	
	for main_key in type_data: # name of type
		
		var type = type_data[main_key]
		
		table_types[main_key] = {"name": type['name'], "params":{}}
		
		for param_key in type['params']:
			
			var param = type["params"][param_key]
			
			table_types[main_key]["params"][param_key] = {"name":param['name'], "type": param['type'], "size": 0, "comment": ""}
			
			if param.size() == 4:
				table_types[main_key]["params"][param_key]['comment'] = param['comment']
				table_types[main_key]["params"][param_key]['size'] = param['size']

func load_file():
	
	var save_path = get_path()
	
	if !_check_path(save_path):
		ASSERT_ERROR(str("The file '",save_path,"' doesn't exist!"))
		return
	
	if _loaded_path == save_path:
		var dic = {"table": get_data(), "type": get_type()}
		return dic
	
	var packedData = load(save_path)
	
	set_data(packedData)
	
	set_type(packedData)
	
	res_loaded.emit(_collection_path)
	_loaded_path = save_path
	
	var dic = {"table": get_data(), "type": get_type()}
	return dic

func save_file():
	if _collection_path.is_empty():
		return
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var datas = {"table": table_datas, "type": table_types}
	
	packedData.pack(datas)
	
	ResourceSaver.save(packedData, _collection_path)
	res_saved.emit(_collection_path)

# private

func _check_path(path: String) -> bool:
	
	if path == null || path.is_empty():
		return false
	
	if !ResourceLoader.exists(path):
		return false
	
	return true
