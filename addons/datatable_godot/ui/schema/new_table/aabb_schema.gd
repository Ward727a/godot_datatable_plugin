@tool
extends HBoxContainer

var x_input: SpinBox
var y_input: SpinBox
var z_input: SpinBox

var w_input: SpinBox
var h_input: SpinBox
var d_input: SpinBox

var v0: HBoxContainer
var v1: HBoxContainer

var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/AABB.png[/img] "

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
	
	v0 = get_child(1).get_child(0)
	v1 = get_child(1).get_child(1)
	
	x_input = v0.get_child(0).get_child(1)
	y_input = v0.get_child(1).get_child(1)
	z_input = v0.get_child(2).get_child(1)
	
	w_input = v1.get_child(0).get_child(1)
	h_input = v1.get_child(1).get_child(1)
	d_input = v1.get_child(2).get_child(1)
	
	
	pass # Replace with function body.


func get_value():
	
	var vx = Vector3(x_input.get_value(), y_input.get_value(), z_input.get_value())
	var vy = Vector3(w_input.get_value(), h_input.get_value(), d_input.get_value())
	
	return str("AB/", vx.x, ",", vx.y, ",", vx.z, ",", vy.x, ",", vy.y, ",", vy.z)



func set_value(new_value: Variant = null):
	
	var data: AABB
	
	if typeof(new_value) == TYPE_AABB:
		data = new_value
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var convert:String = new_value
		
		if convert.begins_with("AB/"):
			convert = convert.replace("AB/", "")
		else:
			return
		
		var converter = convert.split(",")
		
		var vx = Vector3(float(converter[0]), float(converter[1]), float(converter[2]))
		var vy = Vector3(float(converter[3]), float(converter[4]), float(converter[5]))
		
		data = AABB(vx, vy)
	
	if typeof(data) == TYPE_AABB && data != null:
		
		x_input.set_value((round((data.position.x)*10000))/10000)
		y_input.set_value((round((data.position.y)*10000))/10000)
		z_input.set_value((round((data.position.z)*10000))/10000)
		
		w_input.set_value((round((data.size.x)*10000))/10000)
		h_input.set_value((round((data.size.y)*10000))/10000)
		d_input.set_value((round((data.size.z)*10000))/10000)
		
		return
	
	x_input.set_value(0)
	y_input.set_value(0)
	z_input.set_value(0)
	
	w_input.set_value(0)
	h_input.set_value(0)
	d_input.set_value(0)

func set_disabled(disable: bool):
	
	x_input.editable = !disable
	y_input.editable = !disable
	z_input.editable = !disable
	
	w_input.editable = !disable
	h_input.editable = !disable
	d_input.editable = !disable
