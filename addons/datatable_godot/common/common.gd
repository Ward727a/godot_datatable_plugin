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

## timer
@onready var backup_timer: Timer = %backup_timer

const backup_folder: String = "res://datatable_backup/"

var collection_path: String = "":
	set(new_value):
		collection_path = new_value
		if !collection_path.is_empty():
			
			# Working on the backup timer to restart it, reset the signal, and set it again
			backup_timer.stop()
			backup_timer.set_meta('index_backup', 1)
			if backup_timer.timeout.get_connections().size() != 0:
				backup_timer.timeout.disconnect(_dt_backup.get_instance().make)
			backup_timer.timeout.connect(_dt_backup.get_instance().make.bind(new_value))
			backup_timer.start()
			
			# doing a pre-backup for security reason
			_dt_backup.get_instance().make(new_value)

@onready var script_keys: Array = []

const TYPE_STRING = 0
const TYPE_INT = 1
const TYPE_FLOAT = 2
const TYPE_COLOR = 3
const TYPE_VECTOR2 = 4
const TYPE_VECTOR3 = 5
const TYPE_VECTOR4 = 6
const TYPE_BOOL = 7
const TYPE_RESS = 8 # Ressource
const TYPE_QUAT = 9 # Quaternion
const TYPE_RECT = 10
const TYPE_PLANE = 11
const TYPE_T2 = 12 # Transform2D
const TYPE_T3 = 13 # Transform3D
const TYPE_AABB = 14
const TYPE_BASIS = 15
const TYPE_PROJ = 16
const TYPE_MAX = 17

var plugin_version = "1.1.0"

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

signal ask_reload_data

signal presave_data

func _ready():
	script_key_ask.connect(_signal_generate_key)
	
	_dt_resource.get_instance().load_file()

#####################
## Signal Callable ##
#####################

func _signal_generate_key(script_name: String):

	var script_key: int = randi()
	
	if script_keys.has(script_key):
		script_key = randi()
		while script_keys.has(script_key):
			script_key = randi()
	
	script_keys.push_back(script_key)
	
	script_key_response.emit(script_key, script_name)
