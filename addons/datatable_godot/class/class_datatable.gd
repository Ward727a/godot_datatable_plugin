
@icon("res://addons/datatable_godot/icons/datatable.svg")
extends Object
class_name Datatable
##
## This class is used for getting the table you created.
##
## You shouldn't create this class yourself, but use the [method Collection.get_table] to get this class[br]
## [br]
## Example:
## [codeblock]
## func _ready():
##     
##     var collection: Collection = Collection.new("res://datatable.tableCollection.res")
##     
##     if !collection.has_table("myTable"): # Checking if the table exist
##         push_error("The table 'myTable' doesn't exist!")
##         return
##     
##     var datatable: Datatable = collection.get_table("myTable") # Getting the table with the name "myTable"
##     
##     if !datatable.has_item("myItem"): # Checking if the item exist inside the table "myTable"
##         push_error("The table 'myTable' doesn't have 'myItem' key!")
##         return
##     
##     var item: Dictionary = datatable.get_item("myItem") # Getting the item "myItem" inside "myTable"
##     
##     print(item) # print the result
## [/codeblock]
## [b]
## You can copy a personalised template code for your own item / table by right clicking on your table / item
## [/b]
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
signal table_saved(datas: PackedDataContainer)

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

var _collection: Object

# static var

static var _is_table_init: bool = false
static var _saved_table: Dictionary = {}

static var _is_struct_init: bool = false
static var _saved_struct: Dictionary = {}

func _init(collection: Object, table_name: String):
	
	_collection = collection
	
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
	
	if converter.size() != 4:
		return Color()
	
	return Color(
		converter[0].to_float(),
		converter[1].to_float(),
		converter[2].to_float(),
		converter[3].to_float()
	)

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
	
	if converter.size() != 4:
		return Vector4()
	
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
	
	if vec3_str.size() != 2:
		return Vector2()
	
	vec3.x = _round_vector_string(vec3_str[0])
	vec3.y = _round_vector_string(vec3_str[1])
	
	return vec3

static func _convert_string_to_v3(value: String) -> Vector3:
	
	var vec3 = Vector3()
	
	value = value.replace("(","").replace(")", "")
	
	var vec3_str = value.split(",")
	
	if vec3_str.size() != 3:
		return Vector3()
	
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
	
	if converter.size() != 4:
		return Quaternion()
	
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
	
	if converter.size() != 4:
		return Rect2()
	
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
	
	if converter.size() != 4:
		return Plane()
	
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
	
	if converter.size() != 6:
		return Transform2D()
	
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
	
	if converter.size() != 12:
		return Transform3D()
	
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
	
	if converter.size() != 6:
		return AABB()
	
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
	
	if converter.size() != 9:
		return Basis()
	
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
# Found the reason, it's because of the binary representation of the float, so I need to round it to a certain number
static func _convert_string_to_proj(value: String) -> Projection: 
	var convert : String = value
	
	if convert.begins_with("PJ/"):
		convert = convert.replace("PJ/", "")
	
	var converter = convert.split(",")
	
	if converter.size() != 16:
		return Projection()
	
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

func _get_table_datas()->Dictionary:
	
	var table_datas = {}
	
	var packedData = _collection
	
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
				
				
				table_datas[main_key]['rows'][row_key][column_key] = _convert_complex_string_to_data(column_data['type'], column_data['value'])

	
	return table_datas

func _get_table_structs()->Dictionary:
	
	var table_types = {}
	
	var packedData = _collection
	
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

func _save_table(table_data: Dictionary):
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var table_datas = table_data
	var table_types = _get_table_structs()
	table_datas = _convert_comfort_data_to_complex_data(table_datas, table_types)
	
	var datas = {"table": table_datas, "type": table_types}
	
	packedData.pack(datas)
	table_saved.emit(packedData)

func _get_table()->Dictionary:
	
	var table = _get_table_datas()
	
	return table[_table_name]

func _get_structure()->Dictionary:
	
	var struct_data = _get_table_structs()
	
	if struct_data.has(_struct_name):
		return struct_data[_struct_name]
	
	assert(false, str("Can't find the structure: ", _struct_name))
	return {}

func _check_class(Class_to_check: Resource) -> bool:
	# For now it's empty, need to complete it
	return true

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

## Return the data of the item as a dictionary object.[br]
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

## Return the data of the item as a dictionary object.[br]
## Emit: [signal item_getted] & [signal table_getted][br]
## [br]
## See [Structure] for more information about the global structure object, and check the generated class for more information about the specific object.
func get_item_as_object(key: String)->Structure:
	
	var struct_converted_name: String = _struct_name.replace(" ", "_")
	
	var className = str("struct_",struct_converted_name)
	
	if struct_converted_name.is_empty():
		push_error("Can't return the item by the structure class, the structure_name is empty!")
		return null
	
	if !_dt_classDB.class_exist(className):
		push_error(str("Can't return the item by the structure class, the class of the structure (",className,") doesn't exist!\nYou need to create it or generate it first!"))
		return null
	
	var _classResource: Resource = _dt_classDB.class_instantiate(className)
	
	if !_classResource:
		push_error(str("Can't return the item by the structure class, the class created is not valid!"))
		return null
	
	if !_check_class(_classResource):
		push_error(str("Can't return the item by the structure class, the class created is not valid!"))
		return null
	
	var _item = _classResource.new(get_item(key))
	
	if !_item:
		push_error(str("Can't return the item created with the structure class, the item created is not valid, maybe an error with the data provided?"))
		return null
	
	return _item

## Add an item inside the datatable[br]
## Emit: [signal item_added] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func add_item(item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	
	var rows = _get_table_rows()
	var table = _get_table_datas()
	
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
	
	table[_table_name] = _table_data
	
	if save_data:
		_save_table(table)
	
	item_added.emit(item_key, item_data)
	
	return true

## Add an item inside the datatable[br]
## Emit: [signal item_added] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func add_item_as_object(item_key: String, item: Structure, save_data: bool = true)->bool:
	return add_item(item_key, item._get_dict(_struct_data), save_data)

## Remove an item inside the datatable[br]
## Emit: [signal item_removed] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func remove_item(item_key: String, save_data: bool = true)->bool:
	
	var rows = _get_table_rows()
	var table = _get_table_datas()
	
	if is_error(rows):
		return false
	
	if !has_item(item_key):
		var err = {"error":str("The item ",item_key," doesn't exist in ",_table_name)}
		
		is_error(err)
		
		return false
	
	var old_data = rows[item_key]
	
	rows.erase(item_key)
	
	table[_table_name] = _table_data
	
	if save_data:
		_save_table(table)
	
	item_removed.emit(item_key, old_data)
	
	return true

## Set an item inside the datatable[br]
## Emit: [signal item_setted] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func set_item(item_key: String, item_data: Dictionary, save_data: bool = true)->bool:
	var rows = _get_table_rows()
	var table = _get_table_datas()
	
	if is_error(rows):
		return false
	
	if !is_item_compatible(item_data):
		
		var err = {"error":str("The item (",item_key,") data is not compatible with the table ",_table_name)}
		
		is_error(err)
		
		return false
	
	rows[item_key] = item_data
	
	table[_table_name] = _table_data
	
	if save_data:
		_save_table(table)
	
	return true

## Set an item inside the datatable[br]
## Emit: [signal item_setted] & [signal table_saved][br]
## [br]
## Be careful: All edit on the datatable will be saved inside the "datatable.res" if "save_data" arg is not on "false"!
func set_item_as_object(item_key: String, item: Structure, save_data: bool = true)->bool:
	return set_item(item_key, item._get_dict(_struct_data), save_data)

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

## This function return you a the compatible object for the table
func get_void_item_as_object()->Structure:
	var _class = _dt_classDB.class_instantiate("struct_"+_struct_name.replace(" ", "_"))

	if !_class:
		push_error(str("Can't create the void item as object, the class created is not valid!"))
		return null
	
	if !_check_class(_class):
		push_error(str("Can't create the void item as object, the class created is not valid!"))
		return null
	
	return _class.new(get_void_item())

## Function to check if the given item is of the same structure as the table_name[br]
## [br]
## Return:[br]
## - True: The item can be added to the table[br]
## - False: The item can't be added to the table[br]
## [br]
## Args:[br]
## - item: The item that need to be checked[br]
## [br]
## Example:[br]
## [codeblock]
## var item = {"name": "sword", "damage": 10, "durability": 100}
## if datatable.is_item_compatible(item):
##     print("The item is compatible with the table")
## else:
##     print("The item is not compatible with the table")
## [/codeblock]
func is_item_compatible(item: Dictionary)->bool:
	
	if !_struct_data.has('params'):
		
		var err = {"error": str("The structure of the table ", _table_name, " doesn't has the 'params' key - This error should not occur, please inform the developper!")}
		
		is_error(err)
		
		return false
	
	var params = _struct_data['params']
	
	return params.keys() == item.keys()

## Function to check if the given item is of the same structure as the table_name[br]
## [br]
## Return:[br]
## - True: The item can be added to the table[br]
## - False: The item can't be added to the table[br]
## [br]
## Args:[br]
## - item: The item that need to be checked[br]
## [br]
## Example:[br]
## We have a structure with the key "name", "damage" & "durability" named "items", we generated the class "struct_items" from it[br]
## [codeblock]
## var item = struct_items.new({"name": "sword", "damage": 10, "durability": 100})
## if datatable.is_item_object_compatible(item):
##     print("The item is compatible with the table")
## else:
##     print("The item is not compatible with the table")
## [/codeblock]
func is_item_object_compatible(item: Structure)->bool:
	return is_item_compatible(item._get_dict(_struct_data))

## return all the KEY of items found in the table[br]
## Example: [br]
## We have a table with the item "sword", "axe", "bow", and we want to get all the key inside this table[br]
## [codeblock]
## var keys = datatable.get_items_list()
## print(keys) # ["sword", "axe", "bow"] - Will print all the key of the item in the table
##
## var swordValue = datatable.get_item("sword") # Get the item "sword" from the table
## print(swordValue) # Will print the item "sword" value
## [/codeblock]
func get_items_list()->Array:
	
	var rows = _get_table_rows()
	
	return rows.keys()

## Return the name of the rows of the table[br]
## Example: [br]
## We have a structure with the key "name", "damage" & "durability"[br]
## We have a table with the item "sword", "axe", "bow", and we want to get all the key inside this table[br]
## [codeblock]
## var keys = datatable.get_keys_list()
## print(keys) # ["name", "damage", "durability"] - Will print all the key of the structure used in the table
## [/codeblock]
func get_keys_list()->Array:
	
	var keys = []

	for i in _struct_data['params']:
		keys.append(i)
	
	return keys

## Return all the values linked to the key, the key need to be one of the key of the structure[br]
## Example: [br]
## We have a structure with the key "name", "damage" & "durability"[br]
## We have a table with the item "sword", "axe", "bow", and we want to get all the "name" key value[br]
## [codeblock]
## var names = datatable.get_value_of_key("name")
## print(names) # ["sword", "axe", "bow"] - Will print all the name of all the item in the table
## [/codeblock]
func get_value_of_key(key: String):
	
	var rows = _get_table_rows()

	var values = []

	for i in rows:
		if rows[i].has(key):
			values.append(rows[i][key])
	
	return values