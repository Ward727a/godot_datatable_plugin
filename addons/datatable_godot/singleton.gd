##
## This singleton is used to get the data that you created inside the "Datatable" tab.[br]
## Be sure to [b]NOT DELETE[/b] the "datatable.res" that can be found inside your game files![br]
##
## This singleton is totaly obsolote and WILL BE removed in the next update, please replace it with [datatable_]!!
## @deprecated

extends Node

# Public variables

## @deprecated
const TYPE_STRING = 0
## @deprecated
const TYPE_INT = 1
## @deprecated
const TYPE_FLOAT = 2
## @deprecated
const TYPE_COLOR = 3
## @deprecated
const TYPE_VECTOR2 = 4
## @deprecated
const TYPE_VECTOR3 = 5
## @deprecated
const TYPE_VECTOR4 = 6
## @deprecated
const TYPE_BOOL = 7
## @deprecated
const TYPE_MAX = 8

## @deprecated
const SIZE_SINGLE = 0
## @deprecated
const SIZE_ARRAY = 1
## @deprecated
const SIZE_MAX = 2

# Private variables

const _table_allowed_key: Array = ["name", "rows", "size", "structure"]
const _struct_allowed_key: Array = ["name", "params"]
const _table_row_allowed_key: Array = ["name", "columns"]
const _table_column_allowed_key: Array = ["name", "value", "type"]
const _struct_params_allowed_key: Array = ["name", "type"]

var _is_table_init: bool = false
var _saved_table: Dictionary = {}

var _is_struct_init: bool = false
var _saved_struct: Dictionary = {}

# Private Functions

func _round_vector_string(value: String) -> float:
	return (round((float(value))*10000))/10000

func _convert_string_to_color(value: String) -> Color:
	var convert: String = value
	
	if convert.begins_with("C/"):
		convert = convert.replace("C/", "")
	
	var converter = convert.split(",")
	
	return Color(converter[0].to_float(),converter[1].to_float(),converter[2].to_float(),converter[3].to_float())

func _convert_string_to_v4(value: String) -> Vector4:
	var convert: String = value
	
	if convert.begins_with("V4/"):
		convert = convert.replace("V4/", "")
	
	var converter = convert.split(",")
	return Vector4(converter[0].to_float(),converter[1].to_float(),converter[2].to_float(),converter[3].to_float())

func _convert_string_to_v2(value: String) -> Vector2:
	
	var vec3 = Vector2()
	
	value = value.replace("(","").replace(")", "")
	
	var vec3_str = value.split(",")
	
	vec3.x = _round_vector_string(vec3_str[0])
	vec3.y = _round_vector_string(vec3_str[1])
	
	return vec3

func _convert_string_to_v3(value: String) -> Vector3:
	
	var vec3 = Vector3()
	
	value = value.replace("(","").replace(")", "")
	
	var vec3_str = value.split(",")
	
	vec3.x = _round_vector_string(vec3_str[0])
	vec3.y = _round_vector_string(vec3_str[1])
	vec3.z = _round_vector_string(vec3_str[2])
	
	return vec3

func _convert_string_to_bool(value: String) -> bool:
	
	if value == "true":
		return true
	return false

func _convert_color_to_string(value: Color) -> String:
	return str("C/",value[0],",",value[1],",",value[2],",",value[3])

func _convert_v4_to_string(value: Vector4) -> String:
	return str("V4/",value[0],",",value[1],",",value[2],",",value[3])

func _get_table_datas()->Dictionary:
	
	if _is_table_init:
		return _saved_table
	
	if !ResourceLoader.exists("datatable.res"):
		return {}
	
	var table_datas = {}
	
	var packedData = load("datatable.res")
	
	var table_data = packedData['table']
	
	for main_key in table_data:
		
		var data = table_data[main_key]
		
		table_datas[main_key] = {"size": data['size'], "structure": data['structure'], "rows": {}}
		
		
		for row_key in data['rows']:
			
			var row_data = data['rows'][row_key] # name, columns
			
			
			table_datas[main_key]['rows'][row_key] = {}
			
			
			for column_key in row_data['columns']:
				
				var column_data = row_data['columns'][column_key] # name, value, type
				
				
				# As the "size" object has been created after first release, we do a check so if the size
				# is not inside the data, we add it with the default value
				if column_data.size() == 3:
					column_data['size'] = self.SIZE_SINGLE
				
				if column_data['size'] == self.SIZE_ARRAY:
					var arr_raw: String = column_data['value']
					
					if arr_raw.begins_with(" ARR/ "):
						arr_raw = arr_raw.replace(" ARR/ ", "")
					
					var arr: PackedStringArray = arr_raw.split(";")
					
					var arr_value = []
					
					if arr.size() == 1:
						if arr[0].is_empty():
							table_datas[main_key]['rows'][row_key][column_key] = arr_value
							continue
					
					for item in arr:
						
						var arr_item = item
						
						match(column_data["type"]):
							self.TYPE_COLOR:
								arr_item = _convert_string_to_color(item)
							self.TYPE_VECTOR2:
								arr_item = _convert_string_to_v2(item)
							self.TYPE_VECTOR3:
								arr_item = _convert_string_to_v3(item)
							self.TYPE_VECTOR4:
								arr_item = _convert_string_to_v4(item)
							self.TYPE_BOOL:
								arr_item = _convert_string_to_bool(item)
							
						arr_value.append(arr_item)
					
					table_datas[main_key]['rows'][row_key][column_key] = arr_value
					continue
				
				table_datas[main_key]['rows'][row_key][column_key] = column_data['value']
				if column_data['type'] == self.TYPE_COLOR:
					# if is a color, convert it back to color
					table_datas[main_key]['rows'][row_key][column_key] = _convert_string_to_color(column_data['value'])
				
				if column_data['type'] == self.TYPE_VECTOR4:
					# if is a vec4, convert it back to vec4
					table_datas[main_key]['rows'][row_key][column_key] = _convert_string_to_v4(column_data['value'])
				
	
	return table_datas

func _get_table_structs()->Dictionary:
	
	if _is_struct_init:
		return _saved_struct
	
	if !ResourceLoader.exists("datatable.res"):
		return {}
	
	var table_types = {}
	
	var packedData = load("datatable.res")
	
	var type_data = packedData['type']
	
	for main_key in type_data: # name of type
		
		var type = type_data[main_key]
		
		
		table_types[main_key] = {"name": type['name'], "params":{}}
		
		for param_key in type['params']:
			
			var param = type["params"][param_key]
			
			
			table_types[main_key]["params"][param_key] = {"name":param['name'], "type": param['type'], "size": param['size']}
	
	return table_types

func _get_table_rows(table_name: String)->Dictionary:
	
	var table = get_table(table_name)
	
	if is_error(table):
		return table
	
	if table.has('rows'):
		return table['rows']
	
	return {"error":str("The table ",table_name," doesn't contains the 'rows' key!")}

## Convert the data that the user get (with less information to be more compact) to the data that the plugin need
## @deprecated
func _convert_comfort_data_to_complex_data(table_data: Dictionary, structure_data: Dictionary)->Dictionary:
	
	table_data = table_data.duplicate(true)
	
	for table_key in table_data:
		
		var struct_name = table_data[table_key]['structure']
		
		table_data[table_key]['name'] = table_key
		
		for i in table_data[table_key]['rows']:
			
			var columns = table_data[table_key]['rows'][i].duplicate(true)
			
			table_data[table_key]['rows'][i] = {}
			table_data[table_key]['rows'][i]['name'] = i
			table_data[table_key]['rows'][i]['columns'] = columns
			
			var new_columns = {}
			
			for item_key in columns:
				
				var type = structure_data[struct_name]['params'][item_key]['type']
				var value = columns[item_key]
				var size = structure_data[struct_name]['params'][item_key]['size']
				
				# We need to do this for color and v4 because the packedDataContainer doesn't support these type
				# IDK if it's a Godot bug or me that don't know how, but I found this solution
				
				match(size):
					self.SIZE_SINGLE:
						match(type):
							self.TYPE_COLOR:
								value = _convert_color_to_string(value)
							self.TYPE_VECTOR4:
								value = _convert_v4_to_string(value)
					self.SIZE_ARRAY:
						var arr_value = " ARR/ "
						match(type):
							self.TYPE_COLOR:
								for item in value:
									arr_value += _convert_color_to_string(item)
									if value[value.size()-1] != item:
										arr_value += ";"
							self.TYPE_VECTOR4:
								for item in value:
									arr_value += _convert_v4_to_string(item)
									if value[value.size()-1] != item:
										arr_value += ";"
							_:
								for item in value:
									arr_value += value
									if value[value.size()-1] != item:
										arr_value += ";"
						value = arr_value
				
				new_columns[item_key] = {"name": item_key, "value": value, "type": type, "size": size}
			
			table_data[table_key]['rows'][i]['columns'] = new_columns
	
	return table_data

func _save_table():
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var table_datas = _get_table_datas()
	var table_types = _get_table_structs()
	table_datas = _convert_comfort_data_to_complex_data(table_datas, table_types)
	
	var datas = {"table": table_datas, "type": table_types}
	
	
	packedData.pack(datas)
	
	ResourceSaver.save(packedData, "datatable.res")

# Public Functions

## Function to check if the return data is an error or not.[br]
## More precisely, it check if the data has the "error" key in it (if it is, it's an error).[br][br]
## Return:[br]
## -  False: if not an error[br]
## -  True: if it is an error and print an error message (if not already done)[br][br]
## Args:[br]
## -  data_to_check: The data that need to be checked[br]
## -  log: If you want to log an error message (will be done only 1 time by data)[br]
## -  force_log: If you want to log every error message (without the 1 time by data limitation)[br]
## @deprecated
func is_error(data_to_check: Dictionary, log: bool = true, force_log: bool = false)->bool:
	
	push_error("[Datatable] The singleton will be removed at the next update, please use the class datatable_!!")
	
	if data_to_check.has('error'):
		if (!data_to_check.has('logged') && log) || force_log:
			printerr("[DataTable] ", data_to_check['error'])
			data_to_check['logged'] = true
		return true
	
	return false

## Check if the table exist[br]
## For your information: This function is called each time you try to get a table!
## @deprecated
func has_table(table_name: String)->bool:
	
	var table = _get_table_datas()
	
	return table.has(table_name)

## Init all the table inside datatable.res inside memory so it's not needed to do it each time this operation
## Not Needed, but I advice you to do it
## @deprecated
func init_table()->bool:
	
	if _is_table_init:
		return true
	
	_saved_table = _get_table_datas()
	
	if _saved_table == {}:
		return false
	
	_is_table_init = true
	
	return true

## Init all the struct inside datatable.res inside memory so it's not needed to do it each time this operation
## Not Needed, but I advice you to do it
## @deprecated
func init_struct()->bool:
	
	if _is_struct_init:
		return true
	
	_saved_struct = _get_table_structs()
	
	if _saved_struct == {}:
		return false
	
	_is_struct_init = true
	
	return true

## Return the WHOLE table data.[br]
## If you just want to get a specific key from a table, check [b]"get_item"[/b] function![br][br]
## Key of the returned dictionary:[br]
## - size: Size of the table[br]
## - structure: The structure name used by the table[br]
## - rows: The row contained inside the table
## @deprecated
func get_table(table_name: String)->Dictionary:
	
	if !has_table(table_name):
		var err = {"error":str("The table ",table_name," doesn't exist!")}
		
		is_error(err)
		
		return err
	
	var table = _get_table_datas()
	
	return table[table_name]

## Return the list of table that can be found inside the file "datatable.res"
## @deprecated
func get_tables_list()->Array:
	
	var table = _get_table_datas()
	
	return table.keys()

## @deprecated
func get_table_struct(table_name: String)->Dictionary:
	
	var table = get_table(table_name)
	
	if is_error(table):
		return table
	
	if !table.has('structure'):
		var err = {"error": str("The table ",table_name," doesn't contain the 'structure' key - this error should not occur, please inform the developper!")}
		
		is_error(err)
		
		return err
	
	var structure_name = table['structure']
	
	var structure_data = get_struct(structure_name)
	
	is_error(structure_data)
	
	return structure_data

## Return the structure data.
## [br]
## You can use that to manually check the data that you can get from a table
## @deprecated
func get_struct(structure_name: String)->Dictionary:
	
	var structs = _get_table_structs()
	
	if structs.has(structure_name):
		return structs[structure_name]
	
	return {"error": str("The structure ",structure_name," doesn't exist!")}

## Check if an item is in the table.
## @deprecated
func has_item(table_name: String, key: String)->bool:
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return rows
	
	return rows.has(key)

## Return the data of the item.[br]
## [br]
## Here is an example of what you could get from it:[br]
## { "a_string": "little string", "float_object": 0.3241, ..., "vector3 object": (0.1, 1, -5) }
## @deprecated
func get_item(table_name: String, key: String)->Dictionary:
	
	if !has_item(table_name,key):
		var err = {"error":str("The table ",table_name," doesn't contain the item '",key,"' key!")}
		
		is_error(err)
		
		return err
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return rows
	
	return rows[key]

## Add an item inside the datatable[br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
## @deprecated
func add_item(table_name: String, item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return false
	
	if has_item(table_name, item_key):
		var err = {"error":str("The item ",item_key," already exist in ",table_name)}
		
		is_error(err)
		
		return false
	
	if !is_item_compatible(item_data, table_name):
		
		var err = {"error":str("The item (",item_key,") data is not compatible with the table ",table_name)}
		
		is_error(err)
		
		return false
	
	rows[item_key] = item_data
	
	if save_data:
		_save_table()
	
	return true

## Remove an item inside the datatable[br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
## @deprecated
func remove_item(table_name: String, item_key: String, save_data: bool = true)->bool:
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return false
	
	if !has_item(table_name, item_key):
		var err = {"error":str("The item ",item_key," doesn't exist in ",table_name)}
		
		is_error(err)
		
		return false
	
	rows.erase(item_key)
	
	if save_data:
		_save_table()
	
	return true

## Set an item inside the datatable[br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
## @deprecated
func set_item(table_name: String, item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return false
	
	if !is_item_compatible(item_data, table_name):
		
		var err = {"error":str("The item (",item_key,") data is not compatible with the table ",table_name)}
		
		is_error(err)
		
		return false
	
	rows[item_key] = item_data
	
	if save_data:
		_save_table()
	
	return true

## This function return you a dictionary that is pre-filled with the needed key for this table
## @deprecated
func get_void_item(table_name: String)->Dictionary:
	
	var table = get_table(table_name)
	
	if is_error(table):
		return table
	
	var struct = get_struct(table['structure'])
	
	var data = {}
	
	for i in struct['params']:
		
		if struct['params'][i]['size'] == SIZE_ARRAY:
			data[i] = []
			continue
		
		match(struct['params'][i]['type']):
			self.TYPE_STRING:
				data[i] = ""
			self.TYPE_INT:
				data[i] = 0
			self.TYPE_FLOAT:
				data[i] = .0
			self.TYPE_COLOR:
				data[i] = Color.WHITE
			self.TYPE_VECTOR2:
				data[i] = Vector2(0,0)
			self.TYPE_VECTOR3:
				data[i] = Vector3(0,0,0)
			self.TYPE_VECTOR4:
				data[i] = Vector4(0,0,0,0)
			self.TYPE_BOOL:
				data[i] = false
			_:
				data[i] = ""
	
	return data

## Function to check if the given item is of the same structure as the table_name[br]
## [br]
## Return:[br]
## - True: The item can be added to the table
## - False: The item can't be added to the table
## @deprecated
func is_item_compatible(item: Dictionary, table_name: String)->bool:
	
	var structure = get_table_struct(table_name)
	
	if is_error(structure):
		return false
	
	if !structure.has('params'):
		
		var err = {"error": str("The structure of the table ", table_name, " doesn't has the 'params' key - This error should not occur, please inform the developper!")}
		
		is_error(err)
		
		return false
	
	var params = structure['params']
	
	return params.keys() == item.keys()

## return all the KEY of items found in the table
## @deprecated
func get_items_list(table_name: String)->Array:
	
	var rows = _get_table_rows(table_name)
	
	return rows.keys()
