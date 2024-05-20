@tool
extends VBoxContainer

var input: HBoxContainer
var paramValue: HBoxContainer
var text: RichTextLabel
var add_item: Button
var used_schema: HBoxContainer
var item_value_node: Node

@onready var paramName: String = ""

@onready var icon: String = ""

@onready var type: int = -1

@onready var common: Node

func get_type():
	return type
func set_type(new_type: int):
	type = new_type
	
	match(type):
		common.TYPE_STRING:
			icon = "res://addons/datatable_godot/icons/String.svg"
			used_schema = $"../string_schema"
		common.TYPE_INT:
			icon = "res://addons/datatable_godot/icons/int.svg"
			used_schema = $"../int_schema"
		common.TYPE_FLOAT:
			icon = "res://addons/datatable_godot/icons/float.svg"
			used_schema = $"../float_schema"
		common.TYPE_COLOR:
			icon = "res://addons/datatable_godot/icons/Color.svg"
			used_schema = $"../color_schema"
		common.TYPE_VECTOR2:
			icon = "res://addons/datatable_godot/icons/Vector2.svg"
			used_schema = $"../vector2_schema"
		common.TYPE_VECTOR3:
			icon = "res://addons/datatable_godot/icons/Vector3.svg"
			used_schema = $"../vector3_schema"
		common.TYPE_VECTOR4:
			icon = "res://addons/datatable_godot/icons/Vector4.svg"
			used_schema = $"../vector4_schema"
		common.TYPE_BOOL:
			icon = "res://addons/datatable_godot/icons/bool.png"
			used_schema = $"../bool_schema"
	
	input = used_schema.duplicate()
	
	paramValue.add_child(input)
	
	input.set_h_size_flags(SIZE_EXPAND_FILL)
	
	# remove the text as we don't need it
	var text_node = input.get_child(0)
	input.remove_child(text_node)
	
	input.visible = true
	
	item_value_node.used_schema = used_schema
	
	

func set_title(new_name: String):
	text.set_text(str("[img]",icon,"[/img] ",new_name))
	paramName = new_name

func get_title():
	return paramName

# Called when the node enters the scene tree for the first time.
func _ready():
	
	common = $"../../../../../../../../../../signals"
	
	var header = get_child(0)
	
	text = header.get_child(0)
	paramValue = header.get_child(1)
	add_item = header.get_child(2)
	
	item_value_node = get_child(2).get_child(1)
	
	add_item.pressed.connect(add_pressed)
	
	pass # Replace with function body.


func add_pressed():
	
	if type == common.TYPE_STRING:
		input.set_value(input.get_value().replace(";", "").replace(" ARR/ ", ""))
	
	item_value_node.add_item(input.get_value())
	
	common.presave_data.emit()

func get_value():
	return item_value_node.get_items_value()

func set_value(value: Variant = null):
	
	if value == null:
		item_value_node.reset_items()
		return
	
	if typeof(value) != TYPE_STRING:
		return
	
	var str: String = value
	
	if str.begins_with(" ARR/ "):
		str = str.replace(" ARR/ ", "")
	
	var arr: Array = str.split(";")
	
	item_value_node.reset_items()
	
	if arr.size() == 0:
		return
	
	
	for i in arr:
		if i == "":
			continue
		
		item_value_node.add_item(i)
