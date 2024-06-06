

@tool
extends _dt_common
class_name _dt_updater

## Class that manage all the update system of the plugin
##
## This code is using some code from Nathanhoad[br]
## Under the given license of his plugin (link: https://github.com/nathanhoad/godot_input_helper/tree/main)[br]
## See the code for more details!

var _plugin: _dt_plugin
var _http_request: HTTPRequest
var _version_statut: RichTextLabel

var _is_checking_update: bool = false
var _next_version

const check_update_text: String = "[img]res://addons/datatable_godot/icons/Reload.png[/img] Checking for update... "
const up_to_date_text: String = "[img]res://addons/datatable_godot/icons/StatusSuccess.png[/img] [color=lightgreen]Version up-to-date! "
const update_available_text: String = "[img]res://addons/datatable_godot/icons/StatusError.png[/img] [color=#ff768b]An update is available! "
const cant_check_text: String = "[img]res://addons/datatable_godot/icons/StatusWarning.png[/img] [color=ffde66]Couldn't check for update! "

const check_update_tip: String = "The plugin is check for an update..."
const up_to_date_tip: String = "You good to go, you got the last version available!"
const update_available_tip: String = "A new update is available, please update it!"
const cant_check_tip: String = "The plugin couldn't check if an update was available due to an unknown error. Check it manually please!"

const UPDATE_URL: String = "https://api.github.com/repos/Ward727a/godot_datatable_plugin/releases"

signal update_available(new_version: String) ## The plugin has a more recent version available on GitHub
signal update_error ## The plugin couldn't check if a most recent version is available due to an error
signal update_not_needed ## The plugin is already at the most recent version
signal checking_update ## The plugin is checking for an update, need to wait

signal failed ## Failed updating while doing so
signal updated ## Plugin updated, need a restart


static var _INSTANCE: _dt_updater

static func delete():
	_INSTANCE = null

static func get_instance() -> _dt_updater:
	
	if !_INSTANCE || _dt_plugin.get_instance().get_dev_reset_instance() == "true":
		_INSTANCE = _dt_updater.new()
	
	_INSTANCE.load_var()
	return _INSTANCE

# Init

func load_var():
	_plugin = _dt_plugin.get_instance()

# Backend

func _get_http() -> HTTPRequest:
	
	if _http_request:
		return _http_request
	
	_http_request = HTTPRequest.new()
	add_root(_http_request)
	
	_http_request.request_completed.connect(_on_update_resp)
	
	return _http_request

func check_update(label: RichTextLabel):
	
	if _dt_plugin.get_instance().get_dev_stop_update() == "true":
		WARNING("Can't make update as the dev config 'stop_update' is on true!")
		return
	
	if _is_checking_update:
		return
	_is_checking_update = true
	
	_checking_update()
	
	_version_statut = label
	
	_get_http().request(UPDATE_URL)


func _update_available(new_v: String):
	update_available.emit(new_v)
	_next_version = new_v
	_update_statut(update_available_text, update_available_tip)

func _update_not_needed():
	update_not_needed.emit()
	_update_statut(up_to_date_text, up_to_date_tip)

func _checking_update():
	checking_update.emit()
	_update_statut(check_update_text, check_update_tip)

func _update_error():
	update_error.emit()
	_update_statut(cant_check_text, cant_check_tip)

func _update_statut(txt: String, tip: String):
	
	if _version_statut:
		_version_statut.set_text(txt)
		_version_statut.set_tooltip_text(tip)

# Hook

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
func _on_update_resp(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	
	_is_checking_update = false
	
	if result != HTTPRequest.RESULT_SUCCESS:
		_update_error()
		return
	
	var current_version: String = _plugin.get_version()
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY:
		_update_error()
		return
	
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		return _plugin.version_to_number(version) > _plugin.version_to_number(current_version)
	)
	
	if versions.size() > 0:
		_update_available(versions[0].tag_name.substr(1))
		
		_get_http().request_completed.disconnect(_on_update_resp)
	else:
		_update_not_needed()

# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func _on_success_update(new_version):
	EditorInterface.get_resource_filesystem().scan()

	print_rich("\n[b]Updated DataTable to v%s[/b]\n" % new_version)

	var finished_dialog: AcceptDialog = AcceptDialog.new()
	finished_dialog.dialog_text = "Datatable plugin now up to date. It need to restart!"

	var restart_addon = func():
		finished_dialog.queue_free()
		EditorInterface.call_deferred("set_plugin_enabled", "datatable_godot", true)
		EditorInterface.set_plugin_enabled("datatable_godot", false)

	finished_dialog.canceled.connect(restart_addon)
	finished_dialog.confirmed.connect(restart_addon)
	EditorInterface.get_base_control().add_child(finished_dialog)
	finished_dialog.popup_centered()

# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func _on_failed_update() -> void:
	var failed_dialog: AcceptDialog = AcceptDialog.new()
	failed_dialog.dialog_text = "There was a problem downloading the update."
	failed_dialog.canceled.connect(func(): failed_dialog.queue_free())
	failed_dialog.confirmed.connect(func(): failed_dialog.queue_free())
	EditorInterface.get_base_control().add_child(failed_dialog)
	failed_dialog.popup_centered()


# # # Function used by the UI


func save_zip(bytes: PackedByteArray) -> void:
	
	var TEMP_FILE_NAME = _dt_plugin.get_instance().get_update_temp_file()
	
	var file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.flush()

func _on_download_button_pressed() -> bool:
	
	var TEMP_FILE_NAME = _dt_plugin.get_instance().get_update_temp_file()
	var SAFEGUARD_PATH = _dt_plugin.get_instance().get_update_safeguard()
	
	# Safeguard
	if FileAccess.file_exists(SAFEGUARD_PATH):
		ERROR(str("Can't update due to safeguard (please delete: ",SAFEGUARD_PATH,")"))
		failed.emit()
		return false
	_get_http().request_completed.connect(_on_http_request_completed)
	
	_get_http().request(str("https://github.com/Ward727a/godot_datatable_plugin/archive/refs/tags/v",_next_version,".zip"))
	
	return true

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	
	var TEMP_FILE_NAME = _dt_plugin.get_instance().get_update_temp_file()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit()
		return
	
	save_zip(body)
	
	var zip_reader: ZIPReader = ZIPReader.new()
	var success = zip_reader.open(TEMP_FILE_NAME)
	
	if success != OK:
		
		ASSERT_ERROR("Can't open the zip update file")
		return
	var files: PackedStringArray = zip_reader.get_files()
	
	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/datatable_godot"))
	
	var base_path = files[1]
	
	# Remove archive folder
	files.remove_at(0)
	# Remove assets folder
	files.remove_at(0)
	
	for path in files:
		var new_file_path: String = path.replace(base_path,  "")
		
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(str("res://addons/",new_file_path))
		else:
			var file: FileAccess = FileAccess.open(str("res://addons/",new_file_path), FileAccess.WRITE)
			file.store_buffer(zip_reader.read_file(path))
	
	zip_reader.close()
	
	DirAccess.remove_absolute(TEMP_FILE_NAME)
	
	updated.emit(_next_version)

