@tool
extends HBoxContainer

@onready var _item_value_node = %ItemValue
@onready var _item_name_node = %ItemName
@onready var _item_delete_node = %ItemDelete

var type_: int = -1:
	set(new_value):
		if new_value >= _dt_common.TYPE_MAX:
			push_error("Invalid type, must be less than " + str(_dt_common.TYPE_MAX))
			new_value = 0
		type_ = new_value
		_schema = _dt_schema.get_instance().get_schema(type_)

var name_: String = "":
	set(new_value):
		name_ = new_value
		%ItemName.set_text(new_value)

var _schema: Resource = null

func generate_value_node() -> void:

	var schema = _schema.instantiate()

	_item_value_node.add_child(schema)

	if type_ == _dt_common.TYPE_DICT:
		schema._parent = self

	schema.layout_mode = 1 # We want the schema to have the layout mode "Anchors" (0: Container, 1: Anchors)
	schema.set_anchors_preset(PRESET_FULL_RECT)
	schema.get_child(0).visible = false
	schema.visible = true

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

	if !schema:
		return

	schema.set_value(new_value)