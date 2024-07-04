@tool
extends HBoxContainer

var dict_name: String = "":
    set(new_value):
        %ParamName.text = str("[img]res://addons/datatable_godot/icons/dictionary.png[/img] ", new_value)
        dict_name = new_value

var dict_data: Dictionary = {}

var _res_schema_window: Resource = null

@onready var _param_name: RichTextLabel = %ParamName
@onready var _param_interact: Button = %ParamInteract

var _parent: Node = EditorInterface.get_base_control()

func _ready():
    _res_schema_window = load("res://addons/datatable_godot/ui/nodes/schema/dict_win_schema.tscn")
    _param_interact.pressed.connect(_on_open_pressed)

func _on_open_pressed() -> void:

    print("Open editor")

    print(dict_data)

    var schema = _res_schema_window.instantiate()

    var window = ConfirmationDialog.new()

    window.set_title("Edit Dictionary")
    window.add_child(schema)

    window.min_size = Vector2(800, 500)

    _parent.add_child(window)
    window.popup_centered()

    window.close_requested.connect(schema._on_window_close)

    schema.dict_name = dict_name

    for i in dict_data.keys():
        schema.dict_add_item({i: dict_data[i]})
    
    schema.dict_edit.connect(_on_dict_edit)

    pass

func set_title(new_title: String) -> void:
    dict_name = new_title

func set_value(new_value: Variant) -> void:

    if typeof(new_value) == TYPE_STRING:
        var local_dict_data:Dictionary = {}
        var parsed_data:Variant = JSON.parse_string(new_value)
        var is_success:bool = (parsed_data != null)
        
        if is_success:
            local_dict_data = parsed_data
        else:
            push_error("Invalid JSON data")
            return


        if local_dict_data == null || typeof(local_dict_data) != TYPE_DICTIONARY:
            push_error("Invalid dictionary data")
            return
        
        new_value = local_dict_data

    if typeof(new_value) != TYPE_DICTIONARY:
        return
    
    dict_data = new_value

func get_value() -> Dictionary:
    return dict_data

func _on_dict_edit(dict: Dictionary) -> void:
    print(dict)
    dict_data = dict