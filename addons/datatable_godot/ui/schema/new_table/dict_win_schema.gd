@tool
extends HBoxContainer

signal dict_edit(new_value: Dictionary)

@onready var _dict_name_node: RichTextLabel = %ParamName
@onready var _dict_value_node: VBoxContainer = %ParamValue

var dict_name: String = "":
	set(new_value):
		%ParamName.text = new_value
		dict_name = new_value

var _items: Dictionary = {}

@onready var _root_add: Button = %rootAdd
@onready var _root_type: OptionButton = %rootType
@onready var _root_name: LineEdit = %rootName

@onready var _item_list: VBoxContainer = %itemList

func _ready():
	_root_add.pressed.connect(_on_add_pressed)
	_root_name.text_changed.connect(_on_name_changed)

func _on_name_changed(new_name: String) -> void:

	new_name = new_name.strip_edges()
	_root_name.remove_theme_color_override("font_color")

	_root_add.disabled = new_name.is_empty()

	if _items.has(new_name):
		_root_add.disabled = true
		_root_name.add_theme_color_override("font_color", _dt_common.color.ERROR)


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

func dict_add_item(item: Dictionary) -> void:

	var schema = _dt_schema.get_instance().get_schema(_dt_common.TYPE_DICT_ITEM).instantiate()

	if !schema:
		push_error("Schema not instantiated")
		return

	schema.name_ = item.keys()[0]

	schema.type_ = _dt_schema.get_instance().gdType_to_plugType(typeof(item.values()[0]))

	_item_list.add_child(schema)

	_items[schema.name_] = {
		"item": schema,
		"name": schema.name_,
		"type": schema.type_
	}

	schema.generate_value_node()

	var item_value = item.get(schema.name_)

	schema.set_value(item_value)

func _on_window_close() -> void:

	var new_dict: Dictionary = {}

	for key in _items.keys():
		var item: Dictionary = _items[key]

		var name: Variant = item["name"]
		var schema: Control = item["item"]

		new_dict[item.name] = schema.get_value()
	
	dict_edit.emit(new_dict)

	print("close window...")