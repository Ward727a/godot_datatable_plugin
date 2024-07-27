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

var gdsize: int = Variant.Type.TYPE_ARRAY

func get_type():
	return type

func set_type(new_type: int):
	type = new_type
	

	print("type: ", type)
	print("gdSize_to_plugSize: ", _dt_schema.get_instance().gdSize_to_plugSize(type))

	if _dt_schema.get_instance().gdSize_to_plugSize(type) == _dt_schema.SIZE_ARRAY:
		type = _dt_schema.get_instance().gdArray_to_plugType(type)
		print("type: ", type)

	icon = _dt_schema.get_instance().get_icon(type)
	used_schema = _dt_schema.get_instance().get_schema(type)
	
	if !paramValue:
		var header = get_child(0)
		text = header.get_child(0)
		paramValue = header.get_child(1).get_child(0)
		add_item = header.get_child(1).get_child(1)
		item_value_node = get_child(2).get_child(1)
		if !add_item.pressed.is_connected(add_pressed):
			add_item.pressed.connect(add_pressed)

	input = used_schema.instantiate()

	paramValue.add_child(input)
	
	input.set_h_size_flags(SIZE_EXPAND_FILL)
	
	# Hide text node
	input.get_child(0).visible = false
	
	input.visible = true
	
	item_value_node.used_schema = used_schema

func get_gdsize():
	return gdsize

func set_gdsize(gd_size: int):
	gdsize = gd_size

func set_title(new_name: String):
	text.set_text(str("[img]",icon,"[/img] ",new_name))
	paramName = new_name

func get_title():
	return paramName

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var header = get_child(0)
	print("header: ", header)
	text = header.get_child(0)
	print("header_child: ", header.get_children())
	paramValue = header.get_child(1).get_child(0)
	add_item = header.get_child(1).get_child(1)
	
	item_value_node = get_child(2).get_child(1)
	
	add_item.pressed.connect(add_pressed)
	
	pass # Replace with function body.


func add_pressed():
	
	if type == _dt_common.TYPE_STRING:
		input.set_value(input.get_value().replace(";", "").replace(" ARR/ ", ""))
	
	item_value_node.add_item(input.get_value())
	
	# common.presave_data.emit()

func get_value() -> Variant:

	print("gdsize: ", gdsize)

	if gdsize == TYPE_ARRAY:
		return item_value_node.get_items_value()
	
	match(gdsize):
		TYPE_PACKED_COLOR_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedColorArray = PackedColorArray()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_FLOAT32_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedFloat32Array = PackedFloat32Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_FLOAT64_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedFloat64Array = PackedFloat64Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_INT32_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedInt32Array = PackedInt32Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_INT64_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedInt64Array = PackedInt64Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_STRING_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedStringArray = PackedStringArray()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_VECTOR2_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedVector2Array = PackedVector2Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
		TYPE_PACKED_VECTOR3_ARRAY:
			var arr: Array = item_value_node.get_items_value()

			var Packed: PackedVector3Array = PackedVector3Array()

			for i in arr:
				Packed.append(i)
			
			return Packed
	
	return item_value_node.get_items_value()

func set_value(value: Variant = null):
	
	print("arr_schema: ", value)

	if value == null:
		item_value_node.reset_items()
		return

	if _dt_schema.get_instance().gdSize_to_plugSize(typeof(value)) == _dt_common.SIZE_ARRAY:

		item_value_node.reset_items()

		for i in value:
			item_value_node.add_item(i)

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
