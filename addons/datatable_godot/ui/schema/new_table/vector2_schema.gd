@tool
extends HBoxContainer

var vec_input: Node

var x_input: SpinBox
var y_input: SpinBox
var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Vector2.svg[/img] "

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
	x_input = get_child(1).get_child(0).get_child(1)
	y_input = get_child(1).get_child(1).get_child(1)
	
	pass # Replace with function body.


func get_value():
	return Vector2(x_input.get_value(), y_input.get_value())



func set_value(new_value: Variant = null):
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		new_value = new_value.replace("(", "").replace(")", "")
		
		var v2_string: PackedStringArray = new_value.split(",")
		
		if v2_string.size() == 2:
			new_value = Vector2(float(v2_string[0]), float(v2_string[1]))
	
	if typeof(new_value) == TYPE_VECTOR2 && new_value != null:
		x_input.set_value( (round((new_value.x)*10000))/10000)
		y_input.set_value( (round((new_value.y)*10000))/10000)
		return
	x_input.set_value(0)
	y_input.set_value(0)

func set_disabled(disable: bool):
	
	x_input.editable = !disable
	y_input.editable = !disable
