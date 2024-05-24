
@icon("res://addons/datatable_godot/icons/datatable.svg")
class_name datatable_
##
## This class is used for getting the table you created.[br]
## 
## You can call [method init_table] and [method init_struct] so the table 
## and structure data will be saved inside the memory, and not read again and again.[br][br]
## [color=ffde66]Warning: The name of the class (datatable_) is temporary in this version,
## I set it to this so the people that use the singleton will not see their game be broken, but on the
## next update, it will be renamed to "datatable" only![br]
## If you want to, you can delete singleton.gd, then rename this class to "datatable" so on the next update, you will not need to do it again!
## [/color][br][br]
## Example:
## [codeblock]
## func _ready():
##     
##     datatable_.init_table() # initiating the table data inside memory
##     datatable_.init_struct() # initiating the structure data inside memory
##     
##     if !datatable_.has_table("myTable"): # Checking if the table exist
##         push_error("The table 'myTable' doesn't exist!")
##         return
##     
##     var table: datatable_ = datatable_.new("myTable") # Getting the table with the name "myTable"
##     
##     if !table.has_item("myItem"): # Checking if the item exist inside the table "myTable"
##         push_error("The table 'myTable' doesn't have 'myItem' key!")
##         return
##     
##     var item: Dictionary = table.get_item("myItem") # Getting the item "myItem" inside "myTable"
##     
##     print(item) # print the result
## [/codeblock]
##     
##     
## @experimental


# signal

## This signal is emitted when an item is added to the table with [method add_item]
signal item_added(item_name: String, item_data: Dictionary)

## This signal is emitted when an item is removed from the table with [method remove_item]
signal item_removed(item_name: String, item_data: Dictionary)

## This signal is emitted when an item is setted in the table with [method set_item]
signal item_setted(item_name: String, old_data: Dictionary, new_data: Dictionary)

## This signal is emitted when an item is getted from the table with [method get_item]
signal item_getted(item_name: String, item_data: Dictionary)

## This signal is emitted when the table is saved (when calling [method add_item], [method remove_item], or [method set_item])
signal table_saved

## This signal is emitted when the table is getted (example: Calling [method get_item], will emit this signal)
signal table_getted

# Enumeration

## This enumeration is only used for the structure type because all the type are not present inside the plugin.
enum ItemType{
	TYPE_STRING, ## For [String] type
	TYPE_INT, ## For [int] type
	TYPE_FLOAT, ## For [float] type
	TYPE_COLOR, ## For [Color] type
	TYPE_VECTOR2, ## For [Vector2] type
	TYPE_VECTOR3, ## For [Vector3] type
	TYPE_VECTOR4, ## For [Vector4] type
	TYPE_BOOL, ## For [bool] type
	TYPE_RESS, ## For [Resource] type
	TYPE_QUAT, ## For [Quaternion] type
	TYPE_RECT, ## For [Rect2] type
	TYPE_PLANE, ## For [Plane] type
	TYPE_T2, ## For [Transform2D] type
	TYPE_T3, ## For [Transform3D] type
	TYPE_AABB, ## For [AABB] type
	TYPE_BASIS, ## For [Basis] type
	TYPE_PROJ ## FOR [Projection] type
}

## This define if the item return a single value, or an array of value.
enum ItemSize{
	SIZE_SINGLE,
	SIZE_ARRAY
}

# variables

var _table_name: String = ""
var _table_data: Dictionary

var _struct_name: String = ""
var _struct_data: Dictionary

# static var

static var _is_table_init: bool = false
static var _saved_table: Dictionary = {}

static var _is_struct_init: bool = false
static var _saved_struct: Dictionary = {}

func _init(table_name: String):
	if !has_table(table_name):
		assert(false, str("Table ",table_name," doesn't exist!"))
		return
	_table_name = table_name
	_table_data = _get_table()
	
	if is_error(_table_data):
		assert(false, str("Error when trying to get the table ", _table_name))
	
	_struct_name = _table_data['structure']
	_struct_data = _get_structure()

static func _round_vector_string(value: String) -> float:
	return snappedf(float(value), 0.0001)

static func _convert_string_to_color(value: String) -> Color:
	var convert: String = value
	
	if convert.begins_with("C/"):
		convert = convert.replace("C/", "")
	
	var converter = convert.split(",")
	
	return Color(converter[0].to_float(),converter[1].to_float(),converter[2].to_float(),converter[3].to_float())

static func _convert_data_to_complex_string(type: int, data: Variant) -> String:
	
	var value = data
	
	match(type):
		ItemType.TYPE_COLOR:
			value = _convert_color_to_string(data)
		ItemType.TYPE_VECTOR4:
			value = _convert_v4_to_string(data)
		ItemType.TYPE_PLANE:
			value = _convert_plane_to_string(data)
		ItemType.TYPE_RECT:
			value = _convert_rect_to_string(data)
		ItemType.TYPE_T2:
			value = _convert_t2_to_string(data)
		ItemType.TYPE_T3:
			value = _convert_t3_to_string(data)
		ItemType.TYPE_AABB:
			value = _convert_aabb_to_string(data)
		ItemType.TYPE_BASIS:
			value = _convert_basis_to_string(data)
		ItemType.TYPE_PROJ:
			value = _convert_proj_to_string(data)
	
	return value

static func _convert_complex_string_to_data(type: int, data: Variant) -> Variant:
	var item = data
	
	if typeof(data) == TYPE_STRING:
		match(type):
			ItemType.TYPE_COLOR:
				item = _convert_string_to_color(data)
			ItemType.TYPE_VECTOR2:
				item = _convert_string_to_v2(data)
			ItemType.TYPE_VECTOR3:
				item = _convert_string_to_v3(data)
			ItemType.TYPE_VECTOR4:
				item = _convert_string_to_v4(data)
			ItemType.TYPE_BOOL:
				item = _convert_string_to_bool(data)
			ItemType.TYPE_QUAT:
				item = _convert_string_to_quat(data)
			ItemType.TYPE_RECT:
				item = _convert_string_to_rect(data)
			ItemType.TYPE_PLANE:
				item = _convert_string_to_plane(data)
			ItemType.TYPE_T2:
				item = _convert_string_to_t2(data)
			ItemType.TYPE_T3:
				item = _convert_string_to_t3(data)
			ItemType.TYPE_AABB:
				item = _convert_string_to_aabb(data)
			ItemType.TYPE_BASIS:
				item = _convert_string_to_basis(data)
			ItemType.TYPE_PROJ:
				item = _convert_string_to_proj(data)
	return item

static func _convert_string_to_v4(value: String) -> Vector4:
	var convert: String = value
	
	if convert.begins_with("V4/"):
		convert = convert.replace("V4/", "")
	
	var converter = convert.split(",")
	return Vector4(
		_round_vector_string(converter[0]),
		_round_vector_string(converter[1]),
		_round_vector_string(converter[2]),
		_round_vector_string(converter[3])
	)

static func _convert_string_to_v2(value: String) -> Vector2:
	
	var vec3 = Vector2()
	
	value = value.replace("(","").replace(")", "")
	
	var vec3_str = value.split(",")
	
	vec3.x = _round_vector_string(vec3_str[0])
	vec3.y = _round_vector_string(vec3_str[1])
	
	return vec3

static func _convert_string_to_v3(value: String) -> Vector3:
	
	var vec3 = Vector3()
	
	value = value.replace("(","").replace(")", "")
	
	var vec3_str = value.split(",")
	
	vec3.x = _round_vector_string(vec3_str[0])
	vec3.y = _round_vector_string(vec3_str[1])
	vec3.z = _round_vector_string(vec3_str[2])
	
	return vec3

static func _convert_string_to_bool(value: String) -> bool:
	
	if value == "true":
		return true
	return false

static func _convert_string_to_quat(value: String) -> Quaternion:
	var convert: String = value
	
	if convert.begins_with("QT/"):
		convert = convert.replace("QT/", "")
	
	var converter = convert.split(",")
	return Quaternion(
		_round_vector_string(converter[0]),
		_round_vector_string(converter[1]),
		_round_vector_string(converter[2]),
		_round_vector_string(converter[3])
	)

static func _convert_string_to_rect(value: String) -> Rect2:
	var convert: String = value
	
	if convert.begins_with("RECT/"):
		convert = convert.replace("RECT/", "")
	
	var converter = convert.split(",")
	return Rect2(
		_round_vector_string(converter[0]),
		_round_vector_string(converter[1]),
		_round_vector_string(converter[2]),
		_round_vector_string(converter[3])
	)

static func _convert_string_to_plane(value: String) -> Plane:
	var convert : String = value
	
	if convert.begins_with("PL/"):
		convert = convert.replace("PL/", "")
	
	var converter = convert.split(",")
	return Plane(
		_round_vector_string(converter[0]),
		_round_vector_string(converter[1]),
		_round_vector_string(converter[2]),
		_round_vector_string(converter[3])
	)

static func _convert_string_to_t2(value: String) -> Transform2D:
	var convert : String = value
	
	if convert.begins_with("T2/"):
		convert = convert.replace("T2/", "")
	
	var converter = convert.split(",")
	
	return Transform2D(
		Vector2(
			_round_vector_string(converter[0]),
			_round_vector_string(converter[1])
		),
		Vector2(
			_round_vector_string(converter[2]),
			_round_vector_string(converter[3])
		),
		Vector2(
			_round_vector_string(converter[4]),
			_round_vector_string(converter[5])
		)
	)

static func _convert_string_to_t3(value: String) -> Transform3D:
	var convert : String = value
	
	if convert.begins_with("T3/"):
		convert = convert.replace("T3/", "")
	
	var converter = convert.split(",")
	
	return Transform3D(
		Vector3(
			_round_vector_string(converter[0]),
			_round_vector_string(converter[1]),
			_round_vector_string(converter[2])
		),
		Vector3(
			_round_vector_string(converter[3]),
			_round_vector_string(converter[4]),
			_round_vector_string(converter[5])
		),
		Vector3(
			_round_vector_string(converter[6]),
			_round_vector_string(converter[7]),
			_round_vector_string(converter[8])
		),
		Vector3(
			_round_vector_string(converter[9]),
			_round_vector_string(converter[10]),
			_round_vector_string(converter[11])
		)
	)

static func _convert_string_to_aabb(value: String) -> AABB:
	var convert : String = value
	
	if convert.begins_with("AB/"):
		convert = convert.replace("AB/", "")
	
	var converter = convert.split(",")
	
	return AABB(
		Vector3(
			_round_vector_string(converter[0]),
			_round_vector_string(converter[1]),
			_round_vector_string(converter[2])
		),
		Vector3(
			_round_vector_string(converter[3]),
			_round_vector_string(converter[4]),
			_round_vector_string(converter[5])
		)
	)

static func _convert_string_to_basis(value: String) -> Basis:
	var convert : String = value
	
	if convert.begins_with("BS/"):
		convert = convert.replace("BS/", "")
	
	var converter = convert.split(",")
	
	return Basis(
		Vector3(
			_round_vector_string(converter[0]),
			_round_vector_string(converter[1]),
			_round_vector_string(converter[2])
		),
		Vector3(
			_round_vector_string(converter[3]),
			_round_vector_string(converter[4]),
			_round_vector_string(converter[5])
		),
		Vector3(
			_round_vector_string(converter[6]),
			_round_vector_string(converter[7]),
			_round_vector_string(converter[8])
		)
	)

# due to some unknown problem, the value after the dot (.0000) has some strange number added after it
# Tried multiple thing on it, but found nothing to fix the problem
static func _convert_string_to_proj(value: String) -> Projection: 
	var convert : String = value
	
	if convert.begins_with("PJ/"):
		convert = convert.replace("PJ/", "")
	
	var converter = convert.split(",")
	
	return Projection(
		Vector4(
			_round_vector_string(converter[0]),
			_round_vector_string(converter[1]),
			_round_vector_string(converter[2]),
			_round_vector_string(converter[3])
		),
		Vector4(
			_round_vector_string(converter[4]),
			_round_vector_string(converter[5]),
			_round_vector_string(converter[6]),
			_round_vector_string(converter[7])
		),
		Vector4(
			_round_vector_string(converter[8]),
			_round_vector_string(converter[9]),
			_round_vector_string(converter[10]),
			_round_vector_string(converter[11])
		),
		Vector4(
			_round_vector_string(converter[12]),
			_round_vector_string(converter[13]),
			_round_vector_string(converter[14]),
			_round_vector_string(converter[15])
		)
	)

static func _convert_color_to_string(value: Color) -> String:
	return str("C/",value[0],",",value[1],",",value[2],",",value[3])

static func _convert_v4_to_string(value: Vector4) -> String:
	return str("V4/",value[0],",",value[1],",",value[2],",",value[3])

static func _convert_quat_to_string(value: Quaternion) -> String:
	return str("QT/",value.x,",",value.y,",",value.z,",",value.w)

static func _convert_rect_to_string(value: Rect2) -> String:
	return str("RECT/",value.position.x,",",value.position.y,",",value.size.x,",",value.size.y)

static func _convert_plane_to_string(value: Plane) -> String:
	return str("PL/",value.x,",",value.y,",",value.z,",",value.d)

static func _convert_t2_to_string(value: Transform2D) -> String:
	return str("T2/",
	value.x.x,",",value.x.y,",",
	value.y.x,",",value.y.y,",",
	value.origin.x,",",value.origin.y
	)

static func _convert_t3_to_string(value: Transform3D) -> String:
	return str("T3/",
	value.basis.x.x,",",value.basis.x.y,",",value.basis.x.z,",",
	value.basis.y.x,",",value.basis.y.y,",",value.basis.y.z,",",
	value.basis.z.x,",",value.basis.z.y,",",value.basis.z.z,",",
	value.origin.x,",",value.origin.y,",",value.origin.z
	)

static func _convert_aabb_to_string(value: AABB) -> String:
	return str("AB/",
	value.position.x,",",value.position.y,",",value.position.z,",",
	value.size.x,",",value.size.y,",",value.size.z
	)

static func _convert_proj_to_string(value: Projection) -> String:
	return str("PJ/",
	value.x.x,",",value.x.y,",",value.x.z,",",value.x.w,",",
	value.y.x,",",value.y.y,",",value.y.z,",",value.y.w,",",
	value.z.x,",",value.z.y,",",value.z.z,",",value.z.w,",",
	value.w.x,",",value.w.y,",",value.w.z,",",value.w.w
	)

static func _convert_basis_to_string(value: Basis) -> String:
	return str("BS/",
	value.x.x,",",value.x.y,",",value.x.z,",",
	value.y.x,",",value.y.y,",",value.y.z,",",
	value.z.x,",",value.z.y,",",value.z.z
	)

static func _get_table_datas()->Dictionary:
	
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
					column_data['size'] = ItemSize.SIZE_SINGLE
				
				if column_data['size'] == ItemSize.SIZE_ARRAY:
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
						
						var arr_item = _convert_complex_string_to_data(column_data["type"], item)
						
						arr_value.append(arr_item)
					
					table_datas[main_key]['rows'][row_key][column_key] = arr_value
					continue
				
						
				print(column_data['value'])
				table_datas[main_key]['rows'][row_key][column_key] = _convert_complex_string_to_data(column_data['type'], column_data['value'])

	
	return table_datas

static func _get_table_structs()->Dictionary:
	
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

func _get_table_rows()->Dictionary:
	
	if _table_data.has('rows'):
		return _table_data['rows']
	
	return {"error":str("The table ",_table_name," doesn't contains the 'rows' key!")}

# Convert the data that the user get (with less information to be more compact) to the data that the plugin need
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
					ItemSize.SIZE_SINGLE:
						value = _convert_data_to_complex_string(type, value)
					ItemSize.SIZE_ARRAY:
						var arr_value = " ARR/ "
						for item in value:
							arr_value += _convert_data_to_complex_string(type, item)
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
	table_saved.emit()
	
	ResourceSaver.save(packedData, "datatable.res")

func _get_table()->Dictionary:
	
	if !has_table(_table_name):
		var err = {"error":str("The table ",_table_name," doesn't exist!")}
		
		is_error(err)
		
		return err
	
	var table = _get_table_datas()
	
	return table[_table_name]

func _get_structure()->Dictionary:
	
	var struct_data = _get_table_structs()
	
	if struct_data.has(_struct_name):
		return struct_data[_struct_name]
	
	assert(false, str("Can't find the structure: ", _struct_name))
	return {}

## Init all the table inside datatable.res inside memory so it's not needed to do it each time this operation[br]
## Not Needed, but I advice you to do it
static func init_table()->bool:
	
	if _is_table_init:
		return true
	
	_saved_table = _get_table_datas()
	
	if _saved_table == {}:
		return false
	
	_is_table_init = true
	
	return true

## Init all the struct inside datatable.res inside memory so it's not needed to do it each time this operation[br]
## Not Needed, but I advice you to do it
static func init_struct()->bool:
	
	if _is_struct_init:
		return true
	
	_saved_struct = _get_table_structs()
	
	if _saved_struct == {}:
		return false
	
	_is_struct_init = true
	
	return true

## Return the structure data.
## [br]
## You can use that to manually check the data that you can get from a table
## Dictionary key:[br]
## - name[br]
## - params[br]
## - params.[b](key)[/b].name[br]
## - params.[b](key)[/b].size[br]
## - params.[b](key)[/b].type[br]
## [br]
## Example:
## [codeblock]
## {
##     "name": "Simple structure",
##     "params": {
##         "A string": {
##             "name": "A String",
##             "size": 0,
##             "type": 0
##         },
##         "Lot of float": {
##             "name": "An array of float",
##             "size": 1,
##             "type": 2
##         }
##     }
## }
## [/codeblock]
static func get_struct_by_name(struct_name: String)->Dictionary:
	
	var structs = _get_table_structs()
	
	if structs.has(struct_name):
		return structs[struct_name]
	
	return {"error": str("The structure ",struct_name," doesn't exist!")}

## Check if the table exist[br]
## For your information: This function is called each time you try to get a table!
static func has_table(table_name: String)->bool:
	
	var table = _get_table_datas()
	
	return table.has(table_name)

## Function to check if the return data is an error or not.[br]
## More precisely, it check if the data has the "error" key in it (if it is, it's an error).[br][br]
## Return:[br]
## -  False: if not an error[br]
## -  True: if it is an error and print an error message (if not already done)[br][br]
## Args:[br]
## -  data_to_check: The data that need to be checked[br]
## -  log: If you want to log an error message (will be done only 1 time by data)[br]
## -  force_log: If you want to log every error message (without the 1 time by data limitation)[br]
static func is_error(data_to_check: Dictionary, log: bool = true, force_log: bool = false)->bool:
	
	if data_to_check.has('error'):
		if (!data_to_check.has('logged') && log) || force_log:
			push_error("[DataTable] ", data_to_check['error'])
			data_to_check['logged'] = true
		return true
	
	return false

## Return the structure used by the table
func get_struct()->Dictionary:
	return _struct_data

## Check if an item is in the table.
func has_item(key: String)->bool:
	
	var rows = _get_table_rows()
	
	if is_error(rows):
		return false
	
	return rows.has(key)

## Return the data of the item.[br]
## Emit: [signal item_getted] & [signal table_getted][br]
## [br]
## Here is an example of what you could get from it:[br]
## [codeblock]{ "a_string": "little string", "float_object": 0.3241, ..., "vector3 object": (0.1, 1, -5) }[/codeblock]
func get_item(key: String)->Dictionary:
	
	if !has_item(key):
		var err = {"error":str("The table ",_table_name," doesn't contain the item '",key,"' key!")}
		
		is_error(err)
		
		return err
	
	var rows = _get_table_rows()
	
	if is_error(rows):
		return rows
	
	item_getted.emit(key, rows[key])
	
	return rows[key]

## Add an item inside the datatable[br]
## Emit: [signal item_added] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func add_item(item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	
	var rows = _get_table_rows()
	
	if is_error(rows):
		return false
	
	if has_item(item_key):
		var err = {"error":str("The item ",item_key," already exist in ",_table_name)}
		
		is_error(err)
		
		return false
	
	if !is_item_compatible(item_data):
		
		var err = {"error":str("The item (",item_key,") data is not compatible with the table ",_table_name)}
		
		is_error(err)
		
		return false
	
	rows[item_key] = item_data
	
	if save_data:
		_save_table()
	
	item_added.emit(item_key, item_data)
	
	return true

## Remove an item inside the datatable[br]
## Emit: [signal item_removed] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func remove_item(item_key: String, save_data: bool = true)->bool:
	
	var rows = _get_table_rows()
	
	if is_error(rows):
		return false
	
	if !has_item(item_key):
		var err = {"error":str("The item ",item_key," doesn't exist in ",_table_name)}
		
		is_error(err)
		
		return false
	
	var old_data = rows[item_key]
	
	rows.erase(item_key)
	
	if save_data:
		_save_table()
	
	item_removed.emit(item_key, old_data)
	
	return true

## Set an item inside the datatable[br]
## Emit: [signal item_setted] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func set_item(item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	var rows = _get_table_rows()
	
	if is_error(rows):
		return false
	
	if !is_item_compatible(item_data):
		
		var err = {"error":str("The item (",item_key,") data is not compatible with the table ",_table_name)}
		
		is_error(err)
		
		return false
	
	rows[item_key] = item_data
	
	if save_data:
		_save_table()
	
	return true

## This function return you a dictionary that is pre-filled with the needed key for this table
func get_void_item()->Dictionary:
	var data = {}
	
	for i in _struct_data['params']:
		
		if _struct_data['params'][i]['size'] == ItemSize.SIZE_ARRAY:
			data[i] = []
			continue
		
		match(_struct_data['params'][i]['type']):
			ItemType.TYPE_STRING:
				data[i] = ""
			ItemType.TYPE_INT:
				data[i] = 0
			ItemType.TYPE_FLOAT:
				data[i] = .0
			ItemType.TYPE_COLOR:
				data[i] = Color.WHITE
			ItemType.TYPE_VECTOR2:
				data[i] = Vector2(0,0)
			ItemType.TYPE_VECTOR3:
				data[i] = Vector3(0,0,0)
			ItemType.TYPE_VECTOR4:
				data[i] = Vector4(0,0,0,0)
			ItemType.TYPE_BOOL:
				data[i] = false
			ItemType.TYPE_RESS:
				data[i] = "res://"
			ItemType.TYPE_QUAT:
				data[i] = Quaternion(0,0,0,0)
			ItemType.TYPE_RECT:
				data[i] = Rect2(0,0,0,0)
			ItemType.TYPE_PLANE:
				data[i] = Plane(0,0,0,0)
			_:
				data[i] = ""
	
	return data

## Function to check if the given item is of the same structure as the table_name[br]
## [br]
## Return:[br]
## - True: The item can be added to the table[br]
## - False: The item can't be added to the table
func is_item_compatible(item: Dictionary)->bool:
	
	if !_struct_data.has('params'):
		
		var err = {"error": str("The structure of the table ", _table_name, " doesn't has the 'params' key - This error should not occur, please inform the developper!")}
		
		is_error(err)
		
		return false
	
	var params = _struct_data['params']
	
	return params.keys() == item.keys()

## return all the KEY of items found in the table
func get_items_list()->Array:
	
	var rows = _get_table_rows()
	
	return rows.keys()
