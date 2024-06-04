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

