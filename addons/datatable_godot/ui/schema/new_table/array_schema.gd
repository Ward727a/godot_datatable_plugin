@tool
extends VBoxContainer

var input: HBoxContainer
var paramValue: HBoxContainer
var text: RichTextLabel
var add_item: Button
var used_schema: Resource
var item_value_node: Node

@onready var paramName: String = ""

@onready var icon: String = ""

@onready var type: int = -1

@onready var common: Node

func get_type():
	return type
func set_type(new_type: int):
	type = new_type
	
	icon = _dt_schema.get_instance().get_icon(type)
	used_schema = _dt_schema.get_instance().get_schema(type)
	
	input = used_schema.instantiate()
	
	paramValue.add_child(input)
	
	input.set_h_size_flags(SIZE_EXPAND_FILL)
	
	# Hide text node
	input.text.visible = false
	
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
	paramValue = header.get_child(1).get_child(0)
	add_item = header.get_child(1).get_child(1)
	
	item_value_node = get_child(2).get_child(1)
	
	add_item.pressed.connect(add_pressed)
	
	pass # Replace with function body.


func add_pressed():
	
	if type == _dt_common.TYPE_STRING:
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
		item_value_node.reset_items()
		return
	
	
	for i in arr:
		if i == "":
			continue
		
		item_value_node.add_item(i)
