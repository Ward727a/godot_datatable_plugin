@tool
extends Node

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
