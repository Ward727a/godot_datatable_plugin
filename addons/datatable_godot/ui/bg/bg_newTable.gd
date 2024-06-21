@tool
extends Panel

@onready var common: Node = %signals
@onready var ob_tableType: OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer/param_block/MarginContainer/VBoxContainer/table_type_box/OB_tableType
@onready var add_item_but: Button = $VBoxContainer/HBoxContainer/HSplitContainer/VBoxContainer/HBoxContainer/b_addItemTable
@onready var create_table_but: Button = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/b_createTable

@onready var table_data: Dictionary = {}
@onready var type_data: Dictionary = {}

@onready var table_schema_data: Dictionary = {"name": "", "rows": {}, "structure":"", "size": 0}
@onready var row_schema_data: Dictionary = {"name": "", "columns": {}}
@onready var column_schema_data: Dictionary = {"name": "", "value": null, "type": 0}

@onready var script_key: int = -1

@onready var shown: bool = false

@onready var item_blocker: Panel = $VBoxContainer/HBoxContainer/HSplitContainer/Panel2/panel_item_blocker
@onready var param_blocker: Panel = $VBoxContainer/HBoxContainer/VBoxContainer/param_block/panel_param_blocker

@onready var param_block: Panel = $VBoxContainer/HBoxContainer/VBoxContainer/param_block

@onready var table_list: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/table_list

@onready var import_menu: MenuButton = %import_but
@onready var export_menu: MenuButton = %export_but

## SCHEMA

@onready var table_schema: HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/table_list/schema_table

@onready var item_schema: HBoxContainer = $VBoxContainer/HBoxContainer/HSplitContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBC_TableItemList/HBC_tableItemSchema

@onready var item_list: VBoxContainer = $VBoxContainer/HBoxContainer/HSplitContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBC_TableItemList

@onready var param_list: VBoxContainer = $VBoxContainer/HBoxContainer/HSplitContainer/Panel2/MarginContainer/ScrollContainer/VBC_itemTableDataList

signal reload_table_type_options_ask

signal add_table_response

signal reload_item_list

signal create_table(table_name: String)
signal create_table_response(success: bool)
signal select_table(table_node: HBoxContainer)
signal delete_table(table_node: HBoxContainer)
signal change_table_type(new_type_id: int)

signal create_item(item_name: String)
signal create_item_response(success: bool)
signal select_item(item_node: HBoxContainer)
signal delete_item(item_node: HBoxContainer)
signal delete_item_response(success: bool)

@onready var selected_table_data: Dictionary = {}
@onready var selected_table_node: Node

@onready var selected_item_data: Dictionary = {}
@onready var selected_item_node: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	common.toggle_newTable_response.connect(_signal_on_shown)
	common.toggle_main_response.connect(_signal_on_hide)
	
	_dt_resource.get_instance().res_reload.connect(check_data)
	
	common.presave_data.connect(_presave_data)
	
	## custom signal
	create_table.connect(_create_table)
	select_table.connect(_select_table)
	delete_table.connect(_delete_table)
	change_table_type.connect(_change_table_type)
	
	create_item.connect(_create_item)
	select_item.connect(_select_item)
	delete_item.connect(_delete_item)
	
	# connect import menu signals
	import_menu.csv_selected.connect(_import_csv)
	import_menu.cr_selected.connect(_import_cr)

	# connect export menu signals
	export_menu.csv_export.connect(_export_csv)
	# export_menu.cr_export.connect(_export_cr)

	pass # Replace with function body.

func check_data():
	if shown:
		var local_data = _dt_resource.get_instance().load_file()
		
		type_data = local_data['type']
		table_data = local_data['table']
		
		selected_table_data = {}
		reload_table_list()
		reload_items_list()
		param_list._clean(true)
		
		reload_table_type_options_ask.emit(type_data)

func reload_table_list():
	
	for node:HBoxContainer in table_list.get_children():
		if node != table_schema:
			node.queue_free()
	
	for table_name: String in table_data:
		
		var data: Dictionary = table_data[table_name]
		var duplicate_node: HBoxContainer = table_schema.duplicate()
		
		table_list.add_child(duplicate_node)
		
		var text_node = duplicate_node.get_child(0)
		text_node.set_text(data['name'])
		text_node.common = common
		
		duplicate_node.set_meta("table_data", data)
		
		duplicate_node.visible = true
		
		if selected_table_data == data:
			_select_table(duplicate_node)
	
	
	_dt_resource.get_instance().save_file()
	
	pass

func reload_items_list():
	
	
	for node: Node in item_list.get_children():
		if node != item_schema:
			node.visible = false
			node.queue_free()
	
	if selected_table_data == {} || selected_table_node == null:
		return
	
	var data = selected_table_data['rows']
	var structure = selected_table_data['structure']
	
	for i: String in data:
	
		
		var row: Dictionary = data[i]
		var row_name: String = row['name']
		
		var item_duplicate: HBoxContainer = item_schema.duplicate()
		
		item_list.add_child(item_duplicate)
		
		item_duplicate.common = common
		item_duplicate.table_name = selected_table_data['name']
		
		item_duplicate.set_title(row_name)
		item_duplicate.set_data(row)
		
		item_duplicate.item_pressed.connect(_select_item)
		item_duplicate.item_deleted.connect(_delete_item)
		
		item_duplicate.visible = true
		
		if selected_item_node != null:
			if row_name == selected_item_data['name']:
				item_duplicate.select(true)
				selected_item_node = item_duplicate
	
	reload_item_list.emit()
	
	
	_dt_resource.get_instance().save_file()


func _signal_on_shown():
	shown = true
	
	check_data()
	
	_dt_resource.get_instance().save_file()
	return

func _presave_data():
	param_list.save_data_of_struct()
	_dt_resource.get_instance().save_file()

func _signal_on_hide():
	param_list.save_data_of_struct()
	
	shown = false
	
	_dt_resource.get_instance().save_file()
	selected_table_data = {}
	return


func _signal_on_receive_key(key: int, script_name: String):
	if script_name == "bg_newTable":
		script_key = key


func _create_table(table_name: String):
	
	if ob_tableType.item_count == 0:
		create_table_response.emit(false)
		return
	
	if table_data.has(table_name):
		create_table_response.emit(false)
		return
	
	table_data[table_name] = table_schema_data.duplicate(true)
	table_data[table_name]['name'] = table_name
	table_data[table_name]['structure'] = ob_tableType.get_item_metadata(0)['name']
	table_data[table_name]['size'] = 0
	
	create_table_response.emit(true)
	reload_table_list()

func _select_table(table_node: Node):
	
	if !table_node.has_meta("table_data"):
		return
	
	if selected_table_node != null:
		selected_table_node.select(false)
	
	
	if param_blocker.visible == true:
		param_blocker.visible = false
		add_item_but.set_meta('force_disabled',false)
	
	selected_table_node = table_node
	
	if !selected_table_node.get_meta("table_data").has('name'):
		return
	
	selected_table_data = table_data[selected_table_node.get_meta("table_data")['name']]
	
	if !param_block.reload(selected_table_data):
		common.popup_alert_ask.emit("Can't open this data", str("The plugin can't load this data because the structure (structure name: \"",selected_table_data['structure'],"\") used by the table is not found!"))
		return
	
	selected_table_node.select(true)
	
	selected_item_data = {}
	selected_item_node = null
	
	param_list.save_data_of_struct()
	param_list._clean(true)
	
	import_menu.set_disabled(false)
	export_menu.set_disabled(false)

	reload_items_list()

func _delete_table(table_node: Node):
	
	var same_as_selected = (selected_table_node == table_node)
	
	if !table_node.has_meta("table_data"):
		return
	
	
	if same_as_selected:
		## reset all data in window
		selected_table_node = null
		selected_table_data = {}
		param_blocker.visible = true
		add_item_but.set_meta('force_disabled',true)
		add_item_but.disabled = true
		param_block.visible = false
		import_menu.set_disabled(true)
		export_menu.set_disabled(true)
	
	var data = table_node.get_meta('table_data')
	
	if table_data.has(data['name']):
		table_data.erase(data['name'])
	
	table_node.queue_free()
	reload_table_list()

func _change_table_type(new_type: int):
	
	if selected_table_node == null || selected_table_data == {}:
		return
	
	if selected_table_data['rows'].size() != 0:
		return
	
	var new_type_data = ob_tableType.get_item_metadata(new_type)
	var new_type_name = new_type_data['name']
	
	selected_table_data['structure'] = new_type_name


func _create_item(item_name: String):
	
	if selected_table_node == null || selected_table_data == {}:
		create_item_response.emit(false)
		return
	
	if selected_table_data['rows'].has(item_name):
		create_item_response.emit(false)
		return
	
	selected_table_data['rows'][item_name] = {"name": item_name, "columns": {}}
	selected_table_data['size'] += 1
	
	param_block.reload(selected_table_data)
	
	create_item_response.emit(true)
	
	reload_items_list()

func _select_item(item_node: Node):
	
	if !item_node.has_meta("item_data"):
		return
	
	if selected_item_node != null:
		selected_item_node.select(false)
		
	
	selected_item_node = item_node
	selected_item_data = selected_item_node.get_meta("item_data")
	
	param_list.reload(selected_item_data)
	
	selected_item_node.select(true)
	
	_dt_resource.get_instance().save_file()

func _delete_item(item_node: Node):
	
	var same_as_selected = (selected_item_node == item_node)
	
	if !item_node.has_meta("item_data"):
		delete_item_response.emit(false)
		return
	
	if same_as_selected:
		## reset all data in window
		selected_item_node = null
		selected_item_data = {}
	
	var data = item_node.get_meta("item_data")
	if !selected_table_data['rows'].has(data['name']):
		delete_item_response.emit(false)
		return
	
	selected_table_data['rows'].erase(data['name'])
	selected_table_data['size'] = selected_table_data['rows'].size()
	
	param_block.reload(selected_table_data)
	
	item_node.queue_free()
	reload_items_list()
	delete_item_response.emit(true)


func scan_table_name(table_name: String):
	
	if table_data.has(table_name):
		return false
	return true

func scan_item_name(item_name: String):
	
	if item_name.is_empty():
		return false
	
	if selected_table_node == null:
		return false
	
	var table_name = selected_table_data['name']
	
	if !table_data.has(table_name):
		return false
	
	if !table_data[table_name].has('rows'):
		return false
	
	if table_data[table_name]['rows'].has(item_name):
		return false
	
	return true

func _import_csv(csv: String):

	var csv_keys = _dt_importer._csv_get_headers(csv)
	var csv_values = _dt_importer._csv_get_lines(csv)

	if selected_table_data == {}:
		return
	
	var selected_structure = selected_table_data['structure']
	var structure_keys = type_data[selected_structure]['params'].keys()

	var missing_keys: Array = []

	for i in csv_keys:

		if !structure_keys.has(i.to_lower()):
			push_error("CSV has the key \"", i, "\" but the structure \"", selected_structure, "\" doesn't have it!")

			missing_keys.append(i)

			continue
	
	if missing_keys.size() != 0:
		var confirm_import_dialog = ConfirmationDialog.new()
		confirm_import_dialog.set_title("Import CSV - Missing keys")
		confirm_import_dialog.set_text(str("The CSV has keys that are not in the structure of the table. Do you want to import the CSV anyway?\n\nMissing keys (",missing_keys.size()," keys missing on ",csv_keys.size()," keys found in CSV) :\n", missing_keys, "\n\nThe CSV will be imported without the missing keys if you confirm."))

		confirm_import_dialog.confirmed.connect(_import_csv_missing_keys_confirm.bind(csv, missing_keys))
		confirm_import_dialog.min_size = Vector2(400, 200)

		confirm_import_dialog.ok_button_text = "Import anyway"
		confirm_import_dialog.cancel_button_text = "Cancel"

		add_child(confirm_import_dialog)
		confirm_import_dialog.popup_centered()
		return

	_import_csv_missing_keys_confirm(csv, missing_keys)

	pass

func _import_csv_missing_keys_confirm(csv: String, missing_keys: Array):

	var csv_keys = _dt_importer._csv_get_headers(csv)
	var csv_values = _dt_importer._csv_get_lines(csv)

	if selected_table_data == {}:
		return

	var selected_structure = selected_table_data['structure']

	var index = 0

	for item in csv_values:
		
		var columns = {}

		for key in csv_keys:

			key = key.to_lower()

			if missing_keys.has(key):
				continue
			
			columns[key] = {"name": key, "value": item[key], "type": type_data[selected_structure]['params'][key]['type']}
		
		selected_table_data['rows'][str("csv_imported_",index)] = {"name": str("csv_imported_",index), "columns": columns}
		index += 1
	
	print("Imported ", csv_values.size(), " lines from CSV")

	selected_table_data['size'] = selected_table_data['rows'].size()

	reload_items_list()

	pass

func _export_csv(csv_path: String):

	if selected_table_data == {}:
		return

	print("Exporting CSV...")

	var csv_string = _dt_exporter._csv_export(selected_table_data, type_data[selected_table_data['structure']])

	var csv_file = FileAccess.open(csv_path, FileAccess.WRITE)

	if !csv_file:
		push_error("Can't open file (path: ",csv_path,") for writing")
		return
	
	csv_file.store_string(csv_string)

	csv_file.close()

	print("CSV exported to ", csv_path)

	pass

func _import_cr(cr: Resource, type_selected_name: String):

	if selected_table_data == {}:
		return

	print("Importing CR...")

	var missing_keys = _import_cr_check_missing(cr)
	var not_sup_keys = _import_cr_check_not_supported_type(cr, missing_keys)
	var all_not_sup_keys = _import_cr_check_not_supported_type(cr)
	var dict_keys = _import_cr_check_has_dict(cr, not_sup_keys)

	var available_values = _import_cr_get_values(cr)

	if dict_keys.size() != 0:
		push_error("CR has the key(s) \"", dict_keys, "\" that are dictionaries. Dictionaries are not supported yet!")
		return
	
	var customResourceWindow = load("res://addons/datatable_godot/ui/nodes/importer/customResource/customResource.tscn").instantiate()

	add_child(customResourceWindow)

	print("Available values: ", available_values)

	for i in available_values:
		print("try adding: ", i.name, " - ", i.type)
		var valid: bool = true
		
		if missing_keys.has(i.name):
			valid = false
		customResourceWindow._add_item(i.name, i.type, valid)
	
	customResourceWindow.set_title("Import CR - Select values to import")

	customResourceWindow.popup_centered()

	customResourceWindow.vars_selected.connect(_import_ccr_on_selected.bind(cr))
	
	# if missing_keys.size() != 0:

	# 	var confirm_import_dialog = ConfirmationDialog.new()
	# 	confirm_import_dialog.set_title("Import CR - Missing keys")
	# 	confirm_import_dialog.set_text(str("The Custom Resource has keys that are not in the structure of the table. Do you want to import the CR anyway?\n\nMissing keys (",missing_keys.size()," keys missing on ",cr_keys.size()," keys found in CR) :\n", missing_keys, "\n\nThe CR will be imported without the missing keys if you confirm."))

	# 	confirm_import_dialog.confirmed.connect(_import_cr_missing_keys_confirm.bind(cr, missing_keys))
	# 	confirm_import_dialog.min_size = Vector2(400, 200)

	# 	confirm_import_dialog.ok_button_text = "Import anyway"
	# 	confirm_import_dialog.cancel_button_text = "Cancel"


	# 	add_child(confirm_import_dialog)
	# 	confirm_import_dialog.popup_centered()
	# 	return

	pass

func _import_cr_not_compatible_type(cr: Resource, incompatible_keys: Array):
	
	pass

func _import_cr_missing_keys_confirm(cr: Resource, missing_keys: Array):

	var cr_keys = _dt_importer._resource_get_keys(cr)

	if selected_table_data == {}:
		return

	var selected_structure = type_data[selected_table_data['structure']]

	var columns = {}

	for key in cr_keys:

		if missing_keys.has(key):
			continue

		columns[key] = {"name": key, "value": cr.get(key), "type": selected_structure['params'][key]['type']}

	selected_table_data['rows'][str("cr_imported_",cr.resource_path.get_file())] = {"name": str("cr_imported_",cr.resource_path.get_file()), "columns": columns}

	print("Imported ", cr_keys.size() - missing_keys.size(), " lines from CR")

	selected_table_data['size'] = selected_table_data['rows'].size()

	reload_items_list()

	pass

func _import_cr_check_missing(cr: Resource) -> Array:
	
	var cr_keys = _dt_importer._resource_get_keys(cr)
	
	var selected_structure = type_data[selected_table_data['structure']]

	var missing_keys = []

	for i in cr_keys:
		if !selected_structure['params'].keys().has(i.to_lower()):
			push_error("CR has the key \"", i, "\" but the structure \"", selected_structure['name'], "\" doesn't have it!")
			
			missing_keys.append(i)
	
	return missing_keys

func _import_cr_check_not_supported_type(cr: Resource, missing_keys: Array = []) -> Array:
	
	var keys = missing_keys
	
	# var props = _dt_importer._resource_get_props(cr, missing_keys)

	# for i in props:
	# 	pass
	
	return keys

func _import_cr_check_has_dict(cr: Resource, ignored_keys: Array) -> Array:
	
	var keys = []
	
	var props = _dt_importer._resource_get_props(cr, ignored_keys)

	for i in props:
		if i.type == TYPE_DICTIONARY:
			keys.append(i.name)
	
	return keys

func _import_cr_get_values(cr: Resource, ignored_keys: Array = []) -> Array:
	
	var keys = []
	
	var props = _dt_importer._resource_get_props(cr, ignored_keys)

	print("props: ", props)

	for i in props:
		if ignored_keys.has(i.name):
			continue
		keys.append(i)
	
	return keys

func _import_ccr_on_selected(selected: Array, cr: Resource):
	print("selected: ", selected)

	for i in selected:
		print("selected: ", i.name, " - ", i.type)

		# Check if the item is a dictionary
		if i.type.to_int() == TYPE_DICTIONARY:
			_import_ccr_dict(i, cr)
			return

func _import_ccr_dict(selected: Dictionary, cr: Resource):
	print("selected dictionary: ", selected)

	# We check if the resource has the key
	if !cr.get_property_list().filter(func(i): return i.name == selected['name']):
		push_error("The resource doesn't have the key \"", selected['name'], "\"")
		return

	var object_value = cr.get(selected['name'])

	print("object value: ", object_value)

	# We check if the object is a dictionary
	if typeof(object_value) != TYPE_DICTIONARY:
		push_error("The value of the key \"", selected['name'], "\" is not a dictionary")
		return
	
	var dict_keys = object_value.keys()

	# We check if the dictionary has keys

	if dict_keys.size() == 0:
		push_error("The dictionary is empty")
		return

	pass