@tool
extends HBoxContainer

var x_input: SpinBox
var y_input: SpinBox
var z_input: SpinBox
var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Vector3.svg[/img] "

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
	z_input = get_child(1).get_child(2).get_child(1)
	
	pass # Replace with function body.


func get_value():
	return Vector3(x_input.get_value(), y_input.get_value(), z_input.get_value())


func set_value(new_value: Variant = null):
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var converted: Variant = str_to_var(new_value)

		if typeof(converted) != TYPE_VECTOR3:
			push_error("Vector3 schema: Invalid value: " + new_value)
			return
		
		new_value = converted
	
	if typeof(new_value) == TYPE_VECTOR3 && new_value != null:
		x_input.set_value((round((new_value.x)*10000))/10000)
		y_input.set_value((round((new_value.y)*10000))/10000)
		z_input.set_value((round((new_value.z)*10000))/10000)
		return
	x_input.set_value(0)
	y_input.set_value(0)
	z_input.set_value(0)

func set_disabled(disable: bool):
	
	x_input.editable = !disable
	y_input.editable = !disable
	z_input.editable = !disable
