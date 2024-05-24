@tool
extends HBoxContainer

var xx_input: SpinBox
var xy_input: SpinBox
var xz_input: SpinBox
var xo_input: SpinBox

var yx_input: SpinBox
var yy_input: SpinBox
var yz_input: SpinBox
var yo_input: SpinBox

var zx_input: SpinBox
var zy_input: SpinBox
var zz_input: SpinBox
var zo_input: SpinBox

var v0: HBoxContainer
var v1: HBoxContainer
var v2: HBoxContainer

var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Transform3D.png[/img] "

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
	
	var vector_box = get_child(1)
	
	v0 = vector_box.get_child(0)
	v1 = vector_box.get_child(1)
	v2 = vector_box.get_child(2)
	
	xx_input = v0.get_child(0).get_child(1)
	xy_input = v0.get_child(1).get_child(1)
	xz_input = v0.get_child(2).get_child(1)
	xo_input = v0.get_child(3).get_child(1)
	
	yx_input = v1.get_child(0).get_child(1)
	yy_input = v1.get_child(1).get_child(1)
	yz_input = v1.get_child(2).get_child(1)
	yo_input = v1.get_child(3).get_child(1)
	
	zx_input = v2.get_child(0).get_child(1)
	zy_input = v2.get_child(1).get_child(1)
	zz_input = v2.get_child(2).get_child(1)
	zo_input = v2.get_child(3).get_child(1)
	
	
	pass # Replace with function body.


func get_value():
	
	var vx = Vector3(xx_input.get_value(), xy_input.get_value(), xz_input.get_value())
	var vy = Vector3(yx_input.get_value(), yy_input.get_value(), yz_input.get_value())
	var vz = Vector3(zx_input.get_value(), zy_input.get_value(), zz_input.get_value())
	var vo = Vector3(xo_input.get_value(), yo_input.get_value(), zo_input.get_value())
	
	return str("T3/",
	vx.x, ",", vx.y, ",", vx.z, ",",
	vy.x, ",", vy.y, ",", vy.z, ",",
	vz.x, ",", vz.y, ",", vz.z, ",",
	vo.x, ",", vo.y, ",", vo.z
	)



func set_value(new_value: Variant = null):
	
	var data: Transform3D
	
	if typeof(new_value) == TYPE_TRANSFORM3D:
		data = new_value
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var convert:String = new_value
		
		if convert.begins_with("T3/"):
			convert = convert.replace("T3/", "")
		else:
			return
		
		var converter = convert.split(",")
		
		var vx = Vector3(float(converter[0]), float(converter[1]), float(converter[2]))
		var vy = Vector3(float(converter[3]), float(converter[4]), float(converter[5]))
		var vz = Vector3(float(converter[6]), float(converter[7]), float(converter[8]))
		var vo = Vector3(float(converter[9]), float(converter[10]), float(converter[11]))
		
		data = Transform3D(vx, vy, vz, vo)
	
	if typeof(data) == TYPE_TRANSFORM3D && data != null:
	
		var vec_x: Vector3 = data.basis.x
		var vec_y: Vector3 = data.basis.y
		var vec_z: Vector3 = data.basis.z
		var vec_o: Vector3 = data.origin
		
		xx_input.set_value((round((vec_x.x)*10000))/10000)
		xy_input.set_value((round((vec_x.y)*10000))/10000)
		xz_input.set_value((round((vec_x.z)*10000))/10000)
		xo_input.set_value((round((vec_o.x)*10000))/10000)
		
		yx_input.set_value((round((vec_y.x)*10000))/10000)
		yy_input.set_value((round((vec_y.y)*10000))/10000)
		yz_input.set_value((round((vec_y.z)*10000))/10000)
		yo_input.set_value((round((vec_o.y)*10000))/10000)
		
		zx_input.set_value((round((vec_z.x)*10000))/10000)
		zy_input.set_value((round((vec_z.y)*10000))/10000)
		zz_input.set_value((round((vec_z.z)*10000))/10000)
		zo_input.set_value((round((vec_o.z)*10000))/10000)
		
		return
	
	xx_input.set_value(0)
	xy_input.set_value(0)
	xz_input.set_value(0)
	xo_input.set_value(0)
	
	yx_input.set_value(0)
	yy_input.set_value(0)
	yz_input.set_value(0)
	yo_input.set_value(0)
	
	zx_input.set_value(0)
	zy_input.set_value(0)
	zz_input.set_value(0)
	zo_input.set_value(0)

func set_disabled(disable: bool):
	
	xx_input.editable = !disable
	xy_input.editable = !disable
	xz_input.editable = !disable
	xo_input.editable = !disable
	
	yx_input.editable = !disable
	yy_input.editable = !disable
	yz_input.editable = !disable
	yo_input.editable = !disable
	
	zx_input.editable = !disable
	zy_input.editable = !disable
	zz_input.editable = !disable
	zo_input.editable = !disable
