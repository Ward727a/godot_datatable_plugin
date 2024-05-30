extends Object
class_name Collection
##
## This class is used for getting a collection of datatable.
##
## To get the collection, you need the path to your collection file (should end by ".tableCollection.res", or just ".res" if you use the old collection system)[br]
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

var _collection_path: String

var _collection: Object

const _collection_required_key = ["table", "type"]

func _init(collection_path: String):
	
	if !ResourceLoader.exists(collection_path, "PackedDataContainer"):
		assert(false, str("The path ", collection_path, " isn't an collection!"))
	
	var collection = ResourceLoader.load(collection_path)
	
	var required_key: int = 0
	
	for i in collection:
		if _collection_required_key.has(i):
			required_key += 1
	
	if required_key != _collection_required_key.size():
		assert(false, str("The path ", collection_path, " isn't a valid collection file! (missing key)"))
	
	_collection = collection
	_collection_path = collection_path

## Get the table with the given name inside this collection
func get_table(table_name: String) -> Datatable:
	
	if has_table(table_name):
		var table = Datatable.new(_collection, table_name)
		
		table.table_saved.connect(_on_save_collection)
		
		return table
	
	return null

## Check if the table exist inside this collection[br]
## For your information: This function is called each time you try to get a table!
func has_table(table_name: String) -> bool:
	
	var data = _get_table_datas()
	
	return data.has(table_name)

## Check if the structure exist inside this collection[br]
## For your information: This function is called each time you try to get a structure!
func has_struct(struct_name: String) -> bool:
	
	var data = _get_table_structs()
	
	return data.has(struct_name)

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
func get_struct(struct_name: String) -> Dictionary:
	
	if has_struct(struct_name):
		return _get_table_structs()[struct_name]
	
	return {"error": str("The structure ",struct_name," doesn't exist!")}

# Return the tables list of the datatable
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
					column_data['size'] = Datatable.ItemSize.SIZE_SINGLE
				
				if column_data['size'] == Datatable.ItemSize.SIZE_ARRAY:
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
						
						var arr_item = Datatable._convert_complex_string_to_data(column_data["type"], item)
						
						arr_value.append(arr_item)
					
					table_datas[main_key]['rows'][row_key][column_key] = arr_value
					continue
				
				table_datas[main_key]['rows'][row_key][column_key] = Datatable._convert_complex_string_to_data(column_data['type'], column_data['value'])

	
	return table_datas

# Return the structs list of the datatable
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

# response for the save_data signal emitted by the Datatable object
func _on_save_collection(data:PackedDataContainer):
	
	ResourceSaver.save(data, _collection_path)
