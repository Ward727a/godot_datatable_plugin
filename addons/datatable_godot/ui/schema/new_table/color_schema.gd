@tool
extends HBoxContainer

var input: ColorPickerButton
var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Color.svg[/img] "

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


func get_value() -> String:
	
	var color: Color = input.get_pick_color()

	return var_to_str(color)
	

func set_value(new_value: Variant = null):
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var converted: Variant = str_to_var(new_value)

		if typeof(converted) != TYPE_COLOR:
			push_error("Invalid color value: " + new_value)
			return
		
		input.set_pick_color(converted)
		return
	
	if typeof(new_value) == TYPE_COLOR && new_value != null: 
		input.set_pick_color(new_value)
		return
	input.set_pick_color(Color.BLACK)

func set_disabled(disable: bool):
	
	input.disabled = disable
