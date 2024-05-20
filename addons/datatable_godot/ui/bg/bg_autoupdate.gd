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

@tool
extends Panel

signal failed()

signal updated(new_version: String)

const TEMP_FILE_NAME = "user://temp_update_datatable.zip"

@onready var title: Label = $MarginContainer/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/Label
@onready var downloadButton: Button = $MarginContainer/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3/MarginContainer/b_downloadUpdate
@onready var close: Button = $MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/right_top/Button
@onready var http_request: HTTPRequest = $"../../HTTPRequest"

@onready var success_txt: RichTextLabel = $MarginContainer/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/success_txt
@onready var error_txt: RichTextLabel = $MarginContainer/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/error_txt

var next_version: String = "":
	set(new_value):
		next_version = new_value
		title.text = str("The version ",new_value," is available for download!")
	get:
		return next_version

func _ready():
	downloadButton.pressed.connect(_on_download_button_pressed)
	close.pressed.connect(_close_window)

func _close_window():
	self.visible = false

func save_zip(bytes: PackedByteArray) -> void:
	var file: FileAccess = FileAccess.open(TEMP_FILE_NAME, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.flush()

func _on_download_button_pressed() -> void:
	
	# Safeguard
	if FileAccess.file_exists("res://safeguard/safeguard.gd"):
		prints("Can't update due to safeguard (please delete: safeguard/safeguard.gd)")
		failed.emit()
		error_txt.visible = true
		return
	http_request.request_completed.connect(_on_http_request_completed)
	
	http_request.request(str("https://github.com/Ward727a/godot_datatable_plugin/archive/refs/tags/v",next_version,".zip"))
	downloadButton.disabled = true
	downloadButton.text = "Downloading the update..."

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit()
		error_txt.visible = true
		return
	
	save_zip(body)
	
	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/datatable_godot"))
	
	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_NAME)
	var files: PackedStringArray = zip_reader.get_files()
	
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
	
	updated.emit(next_version)
	success_txt.visible = true
