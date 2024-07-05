extends _dt_common
class_name _dt_importer
## Class that manages importing the CSV, JSON, and resources inside the datatable.

static var _temp_simplified_csv = {'md5': "", 'data': [], 'headers': []}

static func _remove_invalid_char(str: String) -> String:

	var invalid_chars = ["\n", "\r", "\t"]

	for i in invalid_chars:
		str = str.replace(i, "")
	
	str = str.replace("\"\"", "\"") # Replace "" with "
	
	str = str.strip_edges()

	return str

static func _simplify_csv(csv: String) -> Dictionary:

	if _temp_simplified_csv && _temp_simplified_csv.has('md5'):
		if _temp_simplified_csv['md5'] == csv.md5_text(): # if the csv is the same as the last one, we return the last simplified version, for performance issues
			return {'data': _temp_simplified_csv['data'], 'headers': _temp_simplified_csv['headers']}

	_temp_simplified_csv = {'md5': csv.md5_text(), 'data': [], 'headers': []}

	var lines = csv.split("\n")

	if lines.size() == 0:
		return {'data': [], 'headers': []}

	var simplified = []

	# We cant split by "," because the values can have "," inside them, so we need to parse the csv manually with RegEx

	var regex = RegEx.new()
	# RegEx from: https://stackoverflow.com/questions/18144431/regex-to-split-a-csv#answer-18147076
	regex.compile('(?:^|,)(?=[^"]|(")?)"?((?(1)(?:[^"]|"")*|[^,"]*))"?(?=,|$)')

	var reg_match = regex.search_all(lines[0])

	var headers = []

	for reg in reg_match:
		headers.append(_remove_invalid_char(reg.get_string(2)).to_lower())

	for i in range(1, lines.size()):

		var values = []

		reg_match = regex.search_all(lines[i])

		for reg in reg_match:
			values.append(reg.get_string(2))

		var row = {}

		if values.size() == 0:
			continue

		for j in range(0, values.size()):

			if values[j] == "":
				continue

			row[headers[j]] = _remove_invalid_char(values[j])
		
		if row.size() == 0:
			continue
		
		simplified.append(row)
	
	_temp_simplified_csv['data'] = simplified
	_temp_simplified_csv['headers'] = headers

	return {'data': simplified, 'headers': headers}

# ############################ #
# ###### JSON Functions ###### #
# ############################ #
# This is still a work in progress!
# The JSON functions are not yet implemented and it's probably not working!

static func _json_get_keys(json: Dictionary) -> PackedStringArray:

	var keys = []

	for i in json.keys():
		keys.append(i)
	
	return keys

static func _json_get_value(json: Dictionary, key: String) -> Variant:

	if !json.has(key):
		push_error("Key not found: " + key)
		return null

	return json[key]


# ########################### #
# ###### CSV Functions ###### #
# ########################### #

static func _csv_get_lines(csv: String, ignored_keys: PackedStringArray = []) -> Array:

	var simplified = _simplify_csv(csv)['data']

	var lines = []

	for i in simplified:
		
		if ignored_keys.size() == 0:
			lines.append(i)
			continue
		
		var line = {}
		for j in i.keys():
			if ignored_keys.has(j):
				continue

			line[j] = i[j]
		
		lines.append(line)
	
	return lines

static func _csv_get_columns(csv: String, ignored_keys: PackedStringArray = []) -> Dictionary:

	var simplified = _simplify_csv(csv)['data']

	var columns = {}

	for i in simplified:
		
		for j in i.keys():
			if ignored_keys.has(j):
				continue

			if !columns.has(j):
				columns[j] = []
			
			columns[j].append(i[j])
	
	return columns

static func _csv_get_headers(csv: String) -> Array:

	var simplified = _simplify_csv(csv)

	return simplified['headers']

static func _csv_get_size(csv: String) -> int:

	var simplified = _simplify_csv(csv)

	return simplified.size() - 1

static func _csv_get_value(csv: String, line: int, key: String) -> Variant:
	
	var simplified = _simplify_csv(csv)

	if line >= simplified['data'].size():
		push_error("Line out of range: " + str(line))
		return null

	if !simplified['headers'].has(key):
		push_error("Key not found: " + key)
		return null

	return simplified['data'][line][key]

# ################################ #
# ###### Resource Functions ###### #
# ################################ #

static func _resource_get_keys(res: Resource):

	if res == null:
		push_error("Resource could not be loaded")
		return []

	var props = []
	var res_props = res.get_property_list()

	print("res_props: " + str(res_props))

	for i in res_props:
		if i['usage'] == 6: # We only want the properties that are editable

			if i['name'] == "script" || i['name'] == "resource_local_to_scene" || i['name'] == "resource_name" :
				continue

			props.append(i['name'])

	return props

static func _resource_get_props(res: Resource, ignored_keys: PackedStringArray = []):

	if res == null:
		push_error("Resource could not be loaded")
		return []
	
	var props = []
	var res_props = res.get_property_list()

	for i in res_props:
		if i['usage'] == 6: # We only want the properties that are editable
			

			if i['name'] == "script" || i['name'] == "resource_local_to_scene" || i['name'] == "resource_name" :
				continue
			
			if ignored_keys.has(i['name']):
				continue
			
			props.append(i)
	
	return props

static func _resource_get_value(res: Resource, key: String) -> Variant:

	if res == null:
		push_error("Resource could not be loaded")
		return null

	if !_resource_get_keys(res).has(key):
		push_error("Key not found: " + key)
		return null

	return res.get(key)

static func _resource_get_values(res: Resource, ignored_keys: PackedStringArray = []) -> Dictionary:

	if res == null:
		push_error("Resource could not be loaded")
		return {}

	var values = {}

	for i in _resource_get_keys(res):

		if ignored_keys.has(i['name']):
			continue
		
		values[i] = res.get(i)
	
	return values

