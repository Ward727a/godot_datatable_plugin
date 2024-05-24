@tool
extends HBoxContainer

var xx_input: SpinBox
var xy_input: SpinBox
var xo_input: SpinBox

var yx_input: SpinBox
var yy_input: SpinBox
var yo_input: SpinBox

var v0: HBoxContainer
var v1: HBoxContainer

var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Transform2D.png[/img] "

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
	
	xx_input = v0.get_child(0).get_child(1)
	xy_input = v0.get_child(1).get_child(1)
	xo_input = v0.get_child(2).get_child(1)
	
	yx_input = v1.get_child(0).get_child(1)
	yy_input = v1.get_child(1).get_child(1)
	yo_input = v1.get_child(2).get_child(1)
	
	
	pass # Replace with function body.


func get_value():
	
	var vx = Vector2(xx_input.get_value(), xy_input.get_value())
	var vy = Vector2(yx_input.get_value(), yy_input.get_value())
	var vo = Vector2(xo_input.get_value(), yo_input.get_value())
	
	return str("T2/", vx.x, ",", vx.y, ",", vy.x, ",", vy.y, ",", vo.x, ",", vo.y)



func set_value(new_value: Variant = null):
	
	var data: Transform2D
	
	if typeof(new_value) == TYPE_TRANSFORM2D:
		data = new_value
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var convert:String = new_value
		
		if convert.begins_with("T2/"):
			convert = convert.replace("T2/", "")
		else:
			return
		
		var converter = convert.split(",")
		
		var vx = Vector2(float(converter[0]), float(converter[1]))
		var vy = Vector2(float(converter[2]),float(converter[3]))
		var vo = Vector2(float(converter[4]),float(converter[5]))
		
		data = Transform2D(vx, vy, vo)
	
	if typeof(data) == TYPE_TRANSFORM2D && data != null:
		
		xx_input.set_value((round((data.x.x)*10000))/10000)
		xy_input.set_value((round((data.x.y)*10000))/10000)
		xo_input.set_value((round((data.origin.x)*10000))/10000)
		
		yx_input.set_value((round((data.y.x)*10000))/10000)
		yy_input.set_value((round((data.y.y)*10000))/10000)
		yo_input.set_value((round((data.origin.y)*10000))/10000)
		
		return
	
	xx_input.set_value(0)
	xy_input.set_value(0)
	xo_input.set_value(0)
	
	yx_input.set_value(0)
	yy_input.set_value(0)
	yo_input.set_value(0)

func set_disabled(disable: bool):
	
	xx_input.editable = !disable
	xy_input.editable = !disable
	xo_input.editable = !disable
	
	yx_input.editable = !disable
	yy_input.editable = !disable
	yo_input.editable = !disable
