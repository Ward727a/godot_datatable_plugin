@tool
extends HBoxContainer

var _item_value_node = %ItemValue
var _item_name_node = %ItemName
var _item_delete_node = %ItemDelete

var type_: int = -1:
	set(new_value):
		type_ = new_value
		_schema = _dt_schema.get_instance().get_schema(type_)

var name_: String = "":
	set(new_value):
		name_ = new_value
		_item_name_node.set_text(new_value)

var _schema: Resource = null

func generate_value_node() -> void:

	var schema = _schema.instantiate()

	_item_value_node.add_child(schema)

	pass