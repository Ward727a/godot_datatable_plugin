@tool
extends HBoxContainer

var input: CheckBox
var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/bool.png[/img] "

@onready var type: int = -1
func get_type():
	return type
func set_type(new_type: int):
	type = new_type

func set_title(new_name: String):
	text.set_text(str(icon,new_name))
	paramName = new_name

func get_title():
	return paramName

# Called when the node enters the scene tree for the first time.
func _ready():
	
	text = get_child(0)
	input = get_child(1)
	
	pass # Replace with function body.


func get_value():
	return input.is_pressed()

func set_value(new_value: Variant = null):
	if typeof(new_value) == TYPE_BOOL && new_value != null: 
		input.set_pressed(new_value)
		return
	if typeof(new_value) == TYPE_STRING && new_value != null:
		if new_value == "true":
			input.set_pressed(true)
			return
		input.set_pressed(false)
		return
	
	input.set_pressed(false)

func set_disabled(disable: bool):
	
	input.disabled = disable
