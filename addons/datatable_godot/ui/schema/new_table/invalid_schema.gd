@tool
extends HBoxContainer

var input: RichTextLabel
var title: RichTextLabel

var value: Variant = ""

@onready var paramName: String = ""
@onready var icon: String = "[img]res://addons/datatable_godot/icons/invalid_type.png[/img] "
@onready var type: int = -1

func get_type():
	return type

func set_type(new_type: int):
	type = new_type

func set_title(new_name: String):
	title.set_text(new_name)
	paramName = new_name

func get_title():
	return paramName

func _ready():
	title = get_child(0)
	input = get_child(1)
	pass # Replace with function body.

func get_value()->Variant:
	return value

func set_value(new_value: Variant = null):

	value = new_value

	if new_value == null:
		input.set_text("null")
	else:
		input.set_text(var_to_str(new_value))

func set_disabled(disable: bool):
	
	# This function is needed to respect the way all schema nodes are used, if it's not present it cause an error
	# when the schema is used in the editor, so need to keep it here even if it's empty and not used
	
	pass