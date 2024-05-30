@tool
extends Control

# This code is using some code from Nathanhoad
# Under the given license of his plugin (https://github.com/nathanhoad/godot_input_helper/tree/main)
# See below for more details!

## import common
@onready var common:Node = %signals


## Popup components - Alert
@onready var pop_alert_main: Popup = $alert
@onready var pop_alert_title: Label = $alert/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/alert_title
@onready var pop_alert_description: RichTextLabel = $alert/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/alert_text

## UI Components - Background
@onready var bg_main: VBoxContainer = $MarginContainer/bg_main
@onready var bg_newTable: Panel = $MarginContainer/bg_newTable
@onready var bg_manageType: Panel = $MarginContainer/bg_manageType
@onready var bg_autoupdate: Panel = $MarginContainer/bg_autoupdate

@onready var http_request: HTTPRequest = $HTTPRequest

@onready var version_statut: RichTextLabel = $MarginContainer/bg_main/Panel/VBoxContainer/HBoxContainer/HBoxContainer3/version_status

const UPDATE_URL: String = "https://api.github.com/repos/Ward727a/godot_datatable_plugin/releases"

var checking_update: bool = false

const check_update_text: String = "[img]res://addons/datatable_godot/icons/Reload.png[/img] Checking for update... "
const up_to_date_text: String = "[img]res://addons/datatable_godot/icons/StatusSuccess.png[/img] [color=lightgreen]Version up-to-date! "
const update_available_text: String = "[img]res://addons/datatable_godot/icons/StatusError.png[/img] [color=#ff768b]An update is available! "
const cant_check_text: String = "[img]res://addons/datatable_godot/icons/StatusWarning.png[/img] [color=ffde66]Couldn't check for update! "

const check_update_tip: String = "The plugin is check for an update..."
const up_to_date_tip: String = "You good to go, you got the last version available!"
const update_available_tip: String = "A new update is available, please update it!"
const cant_check_tip: String = "The plugin couldn't check if an update was available due to an unknown error. Check it manually please!"

const LOCAL_CONFIG_PATH: String = "res://addons/datatable_godot/plugin.cfg"


###############
## Functions ##
###############

func _ready():
	
	## We check if a new update is available or not
	http_request.request_completed.connect(_check_update_resp)
	
	version_statut.pressed.connect(_check_update)
	
	_check_update()
	
	## By security we reset the visible state of the main window to true
	_signal_toggleMain()
	
	## Connect each asking signal for the toggle on/off of UI main window
	common.toggle_main_ask.connect(_signal_toggleMain)
	common.toggle_newTable_ask.connect(_signal_toggleNewTable)
	common.toggle_manageType_ask.connect(_signal_toggleManageType)
	common.popup_alert_ask.connect(_signal_show_alert_popup)
	
	bg_autoupdate.updated.connect(_success_update)
	bg_autoupdate.failed.connect(_failed_update)
	
	common.plugin_version = get_version()

func _disable_all_UI():
	bg_main.visible = false
	bg_newTable.visible = false
	bg_manageType.visible = false

#####################
## Signal Callable ##
#####################

func _signal_toggleMain():
	_disable_all_UI()
	bg_main.visible = true
	
	common.toggle_main_response.emit()

func _signal_toggleNewTable():
	_disable_all_UI()
	bg_newTable.visible = true
	
	common.toggle_newTable_response.emit()

func _signal_toggleManageType():
	_disable_all_UI()
	bg_manageType.visible = true
	
	common.toggle_manageType_response.emit()

func _signal_show_alert_popup(title: String, description: String):
	pop_alert_title.text = title
	pop_alert_description.text = description
	pop_alert_main.show()

func check_for_datatable_change():
	
	common.ask_reload_data.emit()

func _check_update():
	
	if checking_update:
		return
	checking_update = true
	
	version_statut.set_text(check_update_text)
	version_statut.set_tooltip_text(check_update_tip)
	
	http_request.request(UPDATE_URL)

# Original creator of this code part is nathanhoad, I only edited it a little to make it work with mine!
# Github link to his plugin: https://github.com/nathanhoad/godot_input_helper/tree/main
# Thanks to nathanhoad!
# 
# Nathanhoad License:
# MIT License
# Copyright (c) 2022-present Nathan Hoad
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
func _check_update_resp(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	
	checking_update = false
	
	if result != HTTPRequest.RESULT_SUCCESS:
		version_statut.set_text(cant_check_text)
		version_statut.set_tooltip_text(cant_check_tip)
		return
	
	var current_version: String = get_version()
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY:
		version_statut.set_text(cant_check_text)
		version_statut.set_tooltip_text(cant_check_tip)
		return
	
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		return version_to_number(version) > version_to_number(current_version)
	)
	
	if versions.size() > 0:
		version_statut.set_text(update_available_text)
		version_statut.set_tooltip_text(update_available_tip)
		
		version_statut.pressed.disconnect(_check_update)
		version_statut.pressed.connect(_show_update_window)
		
		http_request.request_completed.disconnect(_check_update_resp)
		
		
		_show_update_window()
		bg_autoupdate.next_version = versions[0].tag_name.substr(1)
	else:
		version_statut.set_text(up_to_date_text)
		version_statut.set_tooltip_text(up_to_date_tip)

func _show_update_window():
	bg_autoupdate.visible = true

# Get the current version
# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func get_version() -> String:
	var config: ConfigFile = ConfigFile.new()
	config.load(LOCAL_CONFIG_PATH)
	return config.get_value("plugin", "version")

# Convert a version number to an actually comparable number
# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func version_to_number(version: String) -> int:
	
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()

# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func _success_update(new_version):
	EditorInterface.get_resource_filesystem().scan()

	print_rich("\n[b]Updated DataTable to v%s[/b]\n" % new_version)

	var finished_dialog: AcceptDialog = AcceptDialog.new()
	finished_dialog.dialog_text = "Datatable plugin now up to date. It need to restart!"

	var restart_addon = func():
		finished_dialog.queue_free()
		EditorInterface.call_deferred("set_plugin_enabled", "DataTable", true)
		EditorInterface.set_plugin_enabled("DataTable", false)

	finished_dialog.canceled.connect(restart_addon)
	finished_dialog.confirmed.connect(restart_addon)
	EditorInterface.get_base_control().add_child(finished_dialog)
	finished_dialog.popup_centered()

# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func _failed_update() -> void:
	var failed_dialog: AcceptDialog = AcceptDialog.new()
	failed_dialog.dialog_text = "There was a problem downloading the update."
	failed_dialog.canceled.connect(func(): failed_dialog.queue_free())
	failed_dialog.confirmed.connect(func(): failed_dialog.queue_free())
	EditorInterface.get_base_control().add_child(failed_dialog)
	failed_dialog.popup_centered()
