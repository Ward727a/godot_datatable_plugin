@tool
extends HBoxContainer

@onready var _item_value_node: VBoxContainer = %ItemValue
@onready var _item_name_node: RichTextLabel = %ItemName
@onready var _item_delete_node: Button = %ItemDelete


var type_: int = -1:
	set(new_value):
		if new_value >= _dt_common.TYPE_MAX:
			push_error("[DataTable] Invalid type, must be less than " + str(_dt_common.TYPE_MAX))
			new_value = -1
		type_ = new_value
		_schema = _dt_schema.get_instance().get_schema(type_)

var gdtype_: int = -1:
	set(new_value):
		gdtype_ = new_value

var name_: Variant = "":
	set(new_value):
		name_ = new_value

		var itemName = str(var_to_str(new_value))

		if typeof(name_) == TYPE_STRING:
			itemName = name_

		%ItemName.set_text(itemName)

var size_: int = 0:
	set(new_value):
		size_ = new_value

var raw_value_: Variant = null

var _schema: Resource = null

func generate_value_node() -> void:

	var schema = _schema.instantiate()

	if size_ == _dt_common.SIZE_ARRAY:
		match(gdtype_):
			Variant.Type.TYPE_PACKED_STRING_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_STRING)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_STRING_ARRAY)
			Variant.Type.TYPE_PACKED_INT32_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_INT)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_INT32_ARRAY)
			Variant.Type.TYPE_PACKED_FLOAT32_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_FLOAT)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_FLOAT32_ARRAY)
			Variant.Type.TYPE_PACKED_VECTOR2_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_VECTOR2)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_VECTOR2_ARRAY)
			Variant.Type.TYPE_PACKED_VECTOR3_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_VECTOR3)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_VECTOR3_ARRAY)
			Variant.Type.TYPE_PACKED_COLOR_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_COLOR)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_COLOR_ARRAY)
			Variant.Type.TYPE_PACKED_INT64_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_INT)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_INT64_ARRAY)
			Variant.Type.TYPE_PACKED_FLOAT64_ARRAY:
				schema = _dt_schema.get_instance().array_schema.instantiate()

				schema.set_type(_dt_common.TYPE_FLOAT)
				schema.set_gdsize(Variant.Type.TYPE_PACKED_FLOAT64_ARRAY)

	

	_item_value_node.add_child(schema)

	if type_ == _dt_common.TYPE_DICT:
		schema._parent = self

	schema.layout_mode = 1 # We want the schema to have the layout mode "Anchors" (0: Container, 1: Anchors)
	schema.set_anchors_preset(PRESET_FULL_RECT)
	schema.get_child(0).visible = false
	schema.size_flags_vertical = SIZE_EXPAND_FILL
	schema.visible = true

	if size_ == _dt_common.SIZE_ARRAY:
		schema.get_child(0).visible = true
		if schema.get_child(0).get_child(0):
			schema.get_child(0).get_child(0).visible = false

	pass

func get_value() -> Variant:

	var schema = _item_value_node.get_child(0)

	if !schema:
		return ""

	return schema.get_value()

func set_value(new_value: Variant):
	
	if !new_value:
		return

	var schema = _item_value_node.get_child(0)

	_item_value_node.get_child(0).visible = true

	if !schema:
		return
	
	if size_ == _dt_common.SIZE_ARRAY:
		print(new_value)
		schema.set_value(new_value)
	else:
		schema.set_value(new_value)

	schema.set_value(new_value)