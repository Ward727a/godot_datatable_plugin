# This code is using some code from Nathanhoad
# Under the given license of his plugin (https://github.com/nathanhoad/godot_input_helper/tree/main)
# See below for more details!

@tool
extends _dt_common
class_name _dt_updater

var _plugin: _dt_plugin
var _http_request: HTTPRequest

var _is_checking_update: bool = false

const UPDATE_URL: String = "https://api.github.com/repos/Ward727a/godot_datatable_plugin/releases"

signal update_available(new_version: String)
signal update_error
signal update_not_available
signal checking_update


static var _INSTANCE: _dt_updater = null

static func get_instance() -> _dt_updater:
	
	if _INSTANCE:
		return _INSTANCE
	
	_INSTANCE = _dt_updater.new()
	return _INSTANCE

# Init

func _init():
	_plugin = _dt_plugin.get_instance()

# Backend

func _get_http() -> HTTPRequest:
	
	if _http_request:
		return _http_request
	
	_http_request = HTTPRequest.new()
	add_root(_http_request)
	
	_http_request.request_completed.connect(_on_update_resp)
	
	return _http_request

func check_update():
	
	if _is_checking_update:
		return
	_is_checking_update = true
	
	checking_update.emit()
	
	_get_http().request(UPDATE_URL)

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
		update_error.emit()
		return
	
	var current_version: String = _plugin.get_version()
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY:
		update_error.emit()
		return
	
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		return _plugin.version_to_number(version) > _plugin.version_to_number(current_version)
	)
	
	if versions.size() > 0:
		update_available.emit(versions[0].tag_name.substr(1))
		
		_get_http().request_completed.disconnect(_on_update_resp)
	else:
		update_not_available.emit()

# OC: Nathanhoad (https://github.com/nathanhoad/godot_input_helper/tree/main) under MIT License (see above)
func _on_success_update(new_version):
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
func _on_failed_update() -> void:
	var failed_dialog: AcceptDialog = AcceptDialog.new()
	failed_dialog.dialog_text = "There was a problem downloading the update."
	failed_dialog.canceled.connect(func(): failed_dialog.queue_free())
	failed_dialog.confirmed.connect(func(): failed_dialog.queue_free())
	EditorInterface.get_base_control().add_child(failed_dialog)
	failed_dialog.popup_centered()
