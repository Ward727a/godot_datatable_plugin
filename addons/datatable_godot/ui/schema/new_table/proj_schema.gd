@tool
extends HBoxContainer

var xx_input: SpinBox
var xy_input: SpinBox
var xz_input: SpinBox
var xw_input: SpinBox

var yx_input: SpinBox
var yy_input: SpinBox
var yz_input: SpinBox
var yw_input: SpinBox

var zx_input: SpinBox
var zy_input: SpinBox
var zz_input: SpinBox
var zw_input: SpinBox

var wx_input: SpinBox
var wy_input: SpinBox
var wz_input: SpinBox
var ww_input: SpinBox

var v0: HBoxContainer
var v1: HBoxContainer
var v2: HBoxContainer
var v3: HBoxContainer

var text: RichTextLabel
@onready var paramName: String = ""

@onready var icon: String = "[img]res://addons/datatable_godot/icons/Projection.png[/img] "

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
	v3 = vector_box.get_child(3)
	
	xx_input = v0.get_child(0).get_child(1)
	xy_input = v0.get_child(1).get_child(1)
	xz_input = v0.get_child(2).get_child(1)
	xw_input = v0.get_child(3).get_child(1)
	
	yx_input = v1.get_child(0).get_child(1)
	yy_input = v1.get_child(1).get_child(1)
	yz_input = v1.get_child(2).get_child(1)
	yw_input = v1.get_child(3).get_child(1)
	
	zx_input = v2.get_child(0).get_child(1)
	zy_input = v2.get_child(1).get_child(1)
	zz_input = v2.get_child(2).get_child(1)
	zw_input = v2.get_child(3).get_child(1)
	
	wx_input = v3.get_child(0).get_child(1)
	wy_input = v3.get_child(1).get_child(1)
	wz_input = v3.get_child(2).get_child(1)
	ww_input = v3.get_child(3).get_child(1)
	
	
	pass # Replace with function body.


func get_value():
	
	var vx = Vector4(xx_input.get_value(), xy_input.get_value(), xz_input.get_value(), xw_input.get_value())
	var vy = Vector4(yx_input.get_value(), yy_input.get_value(), yz_input.get_value(), yw_input.get_value())
	var vz = Vector4(zx_input.get_value(), zy_input.get_value(), zz_input.get_value(), zw_input.get_value())
	var vw = Vector4(wx_input.get_value(), wy_input.get_value(), wz_input.get_value(), ww_input.get_value())
	
	
	return str("PJ/",
	snapped(vx.x, 0.0001), ",", snapped(vx.y, 0.0001), ",", snapped(vx.z, 0.0001), ",", snapped(vx.w, 0.0001), ",",
	snapped(vy.x, 0.0001), ",", snapped(vy.y, 0.0001), ",", snapped(vy.z, 0.0001), ",", snapped(vy.w, 0.0001), ",",
	snapped(vz.x, 0.0001), ",", snapped(vz.y, 0.0001), ",", snapped(vz.z, 0.0001), ",", snapped(vz.w, 0.0001), ",",
	snapped(vw.x, 0.0001), ",", snapped(vw.y, 0.0001), ",", snapped(vw.z, 0.0001), ",", snapped(vw.w, 0.0001)
	)



func set_value(new_value: Variant = null):
	
	var data: Projection
	
	if typeof(new_value) == TYPE_PROJECTION:
		data = new_value
	
	if typeof(new_value) == TYPE_STRING && new_value != null:
		
		var convert:String = new_value
		
		if convert.begins_with("PJ/"):
			convert = convert.replace("PJ/", "")
		else:
			return
		
		var converter = convert.split(",")
		
		var vx = Vector4(float(converter[0]), float(converter[1]), float(converter[2]), float(converter[3]))
		var vy = Vector4(float(converter[4]), float(converter[5]), float(converter[6]), float(converter[7]))
		var vz = Vector4(float(converter[8]), float(converter[9]), float(converter[10]), float(converter[11]))
		var vw = Vector4(float(converter[12]), float(converter[13]), float(converter[14]), float(converter[15]))
		
		data = Projection(vx, vy, vz, vw)
	
	if typeof(data) == TYPE_PROJECTION && data != null:
	
		var vec_x: Vector4 = data.x
		var vec_y: Vector4 = data.y
		var vec_z: Vector4 = data.z
		var vec_w: Vector4 = data.w
		
		xx_input.set_value((round((vec_x.x)*10000))/10000)
		xy_input.set_value((round((vec_x.y)*10000))/10000)
		xz_input.set_value((round((vec_x.z)*10000))/10000)
		xw_input.set_value((round((vec_x.w)*10000))/10000)
		
		yx_input.set_value((round((vec_y.x)*10000))/10000)
		yy_input.set_value((round((vec_y.y)*10000))/10000)
		yz_input.set_value((round((vec_y.z)*10000))/10000)
		yw_input.set_value((round((vec_y.w)*10000))/10000)
		
		zx_input.set_value((round((vec_z.x)*10000))/10000)
		zy_input.set_value((round((vec_z.y)*10000))/10000)
		zz_input.set_value((round((vec_z.z)*10000))/10000)
		zw_input.set_value((round((vec_z.w)*10000))/10000)
		
		wx_input.set_value((round((vec_w.x)*10000))/10000)
		wy_input.set_value((round((vec_w.y)*10000))/10000)
		wz_input.set_value((round((vec_w.z)*10000))/10000)
		ww_input.set_value((round((vec_w.w)*10000))/10000)
		
		return
	
	xx_input.set_value(0)
	xy_input.set_value(0)
	xz_input.set_value(0)
	xw_input.set_value(0)
	
	yx_input.set_value(0)
	yy_input.set_value(0)
	yz_input.set_value(0)
	yw_input.set_value(0)
	
	zx_input.set_value(0)
	zy_input.set_value(0)
	zz_input.set_value(0)
	zw_input.set_value(0)
	
	wx_input.set_value(0)
	wy_input.set_value(0)
	wz_input.set_value(0)
	ww_input.set_value(0)

func set_disabled(disable: bool):
	
	xx_input.editable = !disable
	xy_input.editable = !disable
	xz_input.editable = !disable
	xw_input.editable = !disable
	
	yx_input.editable = !disable
	yy_input.editable = !disable
	yz_input.editable = !disable
	yw_input.editable = !disable
	
	zx_input.editable = !disable
	zy_input.editable = !disable
	zz_input.editable = !disable
	zw_input.editable = !disable
	
	wx_input.editable = !disable
	wy_input.editable = !disable
	wz_input.editable = !disable
	ww_input.editable = !disable
