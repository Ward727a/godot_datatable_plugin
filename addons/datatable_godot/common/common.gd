@tool
extends Node

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## Some explanation: Why I created a key system for some signal?           ##
## Simply due to the fact that I use massively the signal system of godot  ##
## and some signal need to be handled only by some specific script at some ##
## specific time, so to make this I make this key system.                  ##
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##

@onready var table_types: Dictionary = {}
@onready var table_datas: Dictionary = {}

@onready var script_keys: Array = []

const TYPE_STRING = 0
const TYPE_INT = 1
const TYPE_FLOAT = 2
const TYPE_COLOR = 3
const TYPE_VECTOR2 = 4
const TYPE_VECTOR3 = 5
const TYPE_VECTOR4 = 6
const TYPE_MAX = 7

const plugin_version = "1.0.0"

signal toggle_plugin_on
signal toggle_plugin_off

signal toggle_main_ask
signal toggle_main_response

signal toggle_newTable_ask
signal toggle_newTable_response
signal toggle_manageTable_ask
signal toggle_manageTable_response

signal toggle_newType_ask
signal toggle_newType_response
signal toggle_manageType_ask
signal toggle_manageType_response

signal toggle_help_ask
signal toggle_help_response

signal add_type_ask(type: Dictionary)
signal add_type_response(success: bool)
signal get_type_ask(key: int)
signal get_type_response(data: Dictionary, key: int)

signal script_key_ask(script_name: String)
signal script_key_response(key: int, script_name: String)

signal get_data_ask(key: int)
signal get_data_response(data: Dictionary, key: int)

signal popup_alert_ask(title: String, description: String)

func _ready():
	script_key_ask.connect(_signal_generate_key)
	toggle_plugin_off.connect(_signal_disconnect_all)
	
	get_type_ask.connect(_signal_get_type)
	get_data_ask.connect(_signal_get_data)
	
	add_type_ask.connect(_signal_add_type)
	
	load_from_ressource()

func disconnect_signal(object: Signal):
	for connection:Dictionary in object.get_connections():
		object.disconnect(connection['callable'])

#####################
## Signal Callable ##
#####################

# I don't really know if this is really usefull, but by security I will keep it here
# It doesn't cause bug for now, so will see in the future
func _signal_disconnect_all():
	
	print("[DataTable] => Disconnecting all signals...")
	
	disconnect_signal(toggle_plugin_on)
	disconnect_signal(toggle_plugin_off)
	disconnect_signal(toggle_main_ask)
	disconnect_signal(toggle_main_response)
	disconnect_signal(toggle_newTable_ask)
	disconnect_signal(toggle_newTable_response)
	disconnect_signal(toggle_manageTable_ask)
	disconnect_signal(toggle_manageTable_response)
	disconnect_signal(toggle_newType_ask)
	disconnect_signal(toggle_newType_response)
	disconnect_signal(toggle_manageType_ask)
	disconnect_signal(toggle_manageType_response)
	disconnect_signal(toggle_help_ask)
	disconnect_signal(toggle_help_response)
	disconnect_signal(add_type_ask)
	disconnect_signal(add_type_response)
	disconnect_signal(get_data_ask)
	disconnect_signal(get_data_response)
	disconnect_signal(get_type_ask)
	disconnect_signal(get_type_response)
	
	disconnect_signal(script_key_ask)
	disconnect_signal(script_key_response)
	
	disconnect_signal(popup_alert_ask)
	
	print("[DataTable] => Disconnected all signals with success!")

## add our new type to the global type list
func _signal_add_type(type: Dictionary):
	
	# if the type given miss one of the parameters, cancel the operation
	if !type.has('name') || !type.has('params'):
		add_type_response.emit(false)
		return
	
	var type_name = type['name']
	
	# if the type name is already registered, cancel the operation
	if table_types.has(type_name):
		add_type_response.emit(false)
		return
	
	table_types[type_name] = type
	
	add_type_response.emit(true)

func _signal_get_type(key: int):
	get_type_response.emit(table_types, key)

func _signal_get_data(key: int):
	load_from_ressource()
	get_data_response.emit(table_datas, key)

func _signal_generate_key(script_name: String):

	var script_key: int = randi()
	
	if script_keys.has(script_key):
		script_key = randi()
		while script_keys.has(script_key):
			script_key = randi()
	
	script_keys.push_back(script_key)
	
	script_key_response.emit(script_key, script_name)


func save_in_ressource():
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var datas = {"table": table_datas, "type": table_types}
	
	packedData.pack(datas)
	
	ResourceSaver.save(packedData, "datatable.res")
	
	pass

func load_from_ressource():
	
	## load table data from the ressource file
	## from here
	if !ResourceLoader.exists("datatable.res"):
		return
	
	var packedData = load("datatable.res")
	
	var table_data = packedData['table']
	
	for main_key in table_data:
		
		var data = table_data[main_key]
		
		table_datas[main_key] = {"name": data['name'], "size": data['size'], "structure": data['structure'], "rows": {}}
		
		for row_key in data['rows']:
			
			var row_data = data['rows'][row_key] # name, columns
			
			table_datas[main_key]['rows'][row_key] = {"name": row_data['name'], "columns": {}}
			
			for column_key in row_data['columns']:
				
				var column_data = row_data['columns'][column_key] # name, value, type
				
				table_datas[main_key]['rows'][row_key]['columns'][column_key] = {"name": column_data['name'], "value": column_data['value'], "type": column_data['type']}
	
	
	
	## to here
	
	var type_data = packedData['type']
	
	for main_key in type_data: # name of type
		
		var type = type_data[main_key]
		
		table_types[main_key] = {"name": type['name'], "params":{}}
		
		for param_key in type['params']:
			
			var param = type["params"][param_key]
			
			table_types[main_key]["params"][param_key] = {"name":param['name'], "type": param['type']}
	
	pass
