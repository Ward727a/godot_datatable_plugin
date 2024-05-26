@tool
extends HBoxContainer

var x_input: SpinBox
var y_input: SpinBox

var w_input: SpinBox
var h_input: SpinBox
var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Rect2.png[/img] "

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
	x_input = get_child(1).get_child(0).get_child(0).get_child(1)
	y_input = get_child(1).get_child(0).get_child(1).get_child(1)
	w_input = get_child(1).get_child(1).get_child(0).get_child(1)
	h_input = get_child(1).get_child(1).get_child(1).get_child(1)
	
	pass # Replace with function body.


func get_value():
	return str("RECT/",x_input.get_value(),",", y_input.get_value(),",", w_input.get_value(),",", h_input.get_value())



func set_value(new_value: Variant = null):
	
	if typeof(new_value) == TYPE_STRING:
		
		var convert:String = new_value
		
		if convert.begins_with("RECT/"):
			convert = convert.replace("RECT/", "")
		else:
			return
		
		var converter = convert.split(",")
		
		new_value = Rect2(float(converter[0]),float(converter[1]),float(converter[2]),float(converter[3]))
	
	if typeof(new_value) == TYPE_RECT2 && new_value != null:
		x_input.set_value( (round((new_value.position.x)*10000))/10000)
		y_input.set_value( (round((new_value.position.y)*10000))/10000)
		w_input.set_value( (round((new_value.size.x)*10000))/10000)
		h_input.set_value( (round((new_value.size.y)*10000))/10000)
		return
	x_input.set_value(0)
	y_input.set_value(0)
	w_input.set_value(0)
	h_input.set_value(0)

func set_disabled(disable: bool):
	
	x_input.editable = !disable
	y_input.editable = !disable
	w_input.editable = !disable
	h_input.editable = !disable
