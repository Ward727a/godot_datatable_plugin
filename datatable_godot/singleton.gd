##
## This singleton is used to get the data that you created inside the "Datatable" tab.[br]
## Be sure to [b]NOT DELETE[/b] the "datatable.res" that can be found inside your game files![br]

extends Node

# Public variables

const TYPE_STRING = 0
const TYPE_INT = 1
const TYPE_FLOAT = 2
const TYPE_COLOR = 3
const TYPE_VECTOR2 = 4
const TYPE_VECTOR3 = 5
const TYPE_VECTOR4 = 6
const TYPE_MAX = 7

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
				
				
				table_datas[main_key]['rows'][row_key][column_key] = column_data['value']
				if column_data['type'] == 3:
					# if is a color, convert it back to color
					var convert: String = column_data['value']
					
					if convert.begins_with("C/"):
						convert = convert.replace("C/", "")
					
					var converter = convert.split(",")
					
					table_datas[main_key]['rows'][row_key][column_key] = Color(converter[0].to_float(),converter[1].to_float(),converter[2].to_float(),converter[3].to_float())
				
				if column_data['type'] == 6:
					# if is a vec4, convert it back to vec4
					var convert: String = column_data['value']
					
					if convert.begins_with("V4/"):
						convert = convert.replace("V4/", "")
					
					var converter = convert.split(",")
					
					table_datas[main_key]['rows'][row_key][column_key] = Vector4(converter[0].to_float(),converter[1].to_float(),converter[2].to_float(),converter[3].to_float())
				
	
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
			
			
			table_types[main_key]["params"][param_key] = {"name":param['name'], "type": param['type']}
	
	return table_types

func _get_table_rows(table_name: String)->Dictionary:
	
	var table = get_table(table_name)
	
	if is_error(table):
		return table
	
	if table.has('rows'):
		return table['rows']
	
	return {"error":str("The table ",table_name," doesn't contains the 'rows' key!")}

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
func is_error(data_to_check: Dictionary, log: bool = true, force_log: bool = false)->bool:
	
	if data_to_check.has('error'):
		if (!data_to_check.has('logged') && log) || force_log:
			printerr("[DataTable] ", data_to_check['error'])
			data_to_check['logged'] = true
		return true
	
	return false

## Check if the table exist[br]
## For your information: This function is called each time you try to get a table!
func has_table(table_name: String)->bool:
	
	var table = _get_table_datas()
	
	return table.has(table_name)

## Init all the table inside datatable.res inside memory so it's not needed to do it each time this operation
## Not Needed, but I advice you to do it
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
func get_table(table_name: String)->Dictionary:
	
	if !has_table(table_name):
		var err = {"error":str("The table ",table_name," doesn't exist!")}
		
		is_error(err)
		
		return err
	
	var table = _get_table_datas()
	
	return table[table_name]

## Return the list of table that can be found inside the file "datatable.res"
func get_tables_list()->Array:
	
	var table = _get_table_datas()
	
	return table.keys()

## Return the structure data.
## [br]
## You can use that to manually check the data that you can get from a table
func get_struct(structure_name: String)->Dictionary:
	
	var structs = _get_table_structs()
	
	if structs.has(structure_name):
		return structs[structure_name]
	
	return {}

## Check if an item is in the table.
func has_item(table_name: String, key: String)->bool:
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return rows
	
	return rows.has(key)

## Return the data of the item.[br]
## [br]
## Here is an example of what you could get from it:[br]
## { "a_string": "little string", "float_object": 0.3241, ..., "vector3 object": (0.1, 1, -5) }
func get_item(table_name: String, key: String)->Dictionary:
	
	if !has_item(table_name,key):
		var err = {"error":str("The table ",table_name," doesn't contain the item '",key,"' key!")}
		
		is_error(err)
		
		return err
	
	var rows = _get_table_rows(table_name)
	
	if is_error(rows):
		return rows
	
	return rows[key]
	

## return all the KEY of items found in the table
func get_items_list(table_name: String)->Array:
	
	var rows = _get_table_rows(table_name)
	
	return rows.keys()
