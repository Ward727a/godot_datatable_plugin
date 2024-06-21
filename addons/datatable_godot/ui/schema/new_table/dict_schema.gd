@tool
extends HBoxContainer

var _dict_name_node: RichTextLabel = %ParamName
var _dict_value_node: VBoxContainer = %ParamValue

var dict_name: String = "":
	set(new_value):
		_dict_name_node.text = new_value
		dict_name = new_value

var _items: Dictionary = {}

var _root_add: Button = %rootAdd
var _root_type: OptionButton = %rootType
var _root_name: LineEdit = %rootName

var _item_list: VBoxContainer = %itemList

func _ready():
	_root_add.pressed.connect(_on_add_pressed)
	_root_name.text_changed.connect(_on_name_changed)

func _on_name_changed(new_name: String) -> void:

	new_name = new_name.strip_edges()
	_root_name.remove_theme_color_override("font_color")

	_root_add.disabled = new_name.is_empty()

	if _items.has(new_name):
		_root_add.disabled = true
		_root_name.add_color_override("font_color", _dt_common.color.ERROR)


func _on_add_pressed() -> void:

	var type = _root_type.get_selected_id()

	if type == -1:
		push_error("Please select a type")
		return
	
	var name = _root_name.text.strip_edges()

	if name.is_empty():
		push_error("Please enter a name")
		return
	
	var _schema = _dt_schema.get_instance().get_schema(_dt_common.TYPE_DICT_ITEM)

	if !_schema:
		push_error("Schema not found")
		return
	
	var schema = _schema.instantiate()

	if !schema:
		push_error("Schema not instantiated")
		return
	
	schema.name_ = name
	schema.type_ = type

	_item_list.add_child(schema)

	_items[name] = {
		"item": schema,
		"name": name,
		"type": type
	}