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

func _on_download_button_pressed() -> void:
	
	_dt_updater.get_instance().failed.connect(_on_failed_update)
	_dt_updater.get_instance().updated.connect(_on_success_update)
	
	if _dt_updater.get_instance()._on_download_button_pressed():
		error_txt.visible = true
		return
	
	downloadButton.disabled = true
	downloadButton.text = "Downloading the update..."

func _on_failed_update():
	
	error_txt.visible = true
	downloadButton.text = "Error when trying to update!"

func _on_success_update(next_v:String):
	
	success_txt.visible = true
	downloadButton.text = str("Update: ",next_v," done with success!")
