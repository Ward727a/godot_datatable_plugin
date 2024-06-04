@tool
extends HBoxContainer

var text: RichTextLabel
var path_label: Label
var b_open_file: Button
var file_dialog: FileDialog

var param_name: String

const icon: String = "[img]res://addons/datatable_godot/icons/Ressource.png[/img] "

var select_path: String = "res://" :
	set(new_path):
		select_path = str(new_path)
		path_label.set_text(new_path)
		path_label.set_tooltip_text(new_path)
	get:
		return select_path

func _ready():
	text = get_child(0)
	path_label = get_child(1).get_child(0).get_child(0)
	b_open_file = get_child(1).get_child(0).get_child(1)
	file_dialog = b_open_file.get_child(0)
	
	b_open_file.pressed.connect(_on_open_file_pressed)
	
	b_open_file.dropped_file_on.connect(_on_file_selected)
	file_dialog.file_selected.connect(_on_file_selected)
	
	set_title("test")

func _on_open_file_pressed():
	file_dialog.visible = true

func _on_file_selected(file_path: String):
	select_path = file_path

func set_title(new_name: String):
	text.set_text(str(icon,new_name))
	param_name = new_name

func get_title():
	return param_name

func get_value():
	return select_path

func set_value(file_path: Variant = null):
	
	if typeof(file_path) == TYPE_STRING && file_path != null:
		select_path = file_path
		return
	
	select_path = "res://"

func set_disabled(toggle: bool):
	b_open_file.visible = !toggle
