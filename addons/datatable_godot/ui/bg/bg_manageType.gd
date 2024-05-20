@tool
extends Panel

## import common to access signals and enum
@onready var common: Node = %signals

@onready var script_key: int = -1

@onready var types_data: Dictionary = {}

@onready var b_addParam: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/HBoxContainer/b_add_param

@onready var typeList: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
@onready var paramList: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/Panel/MarginContainer/ScrollContainer/VBoxContainer

@onready var schemaType: HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/schema_type
@onready var schemaParam: HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/Panel/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer

@onready var selected_object_key: String = ""
@onready var selected_object_node: Node

@onready var int_icon = "res://addons/datatable_godot/icons/int.svg"
@onready var float_icon = "res://addons/datatable_godot/icons/float.svg"
@onready var str_icon = "res://addons/datatable_godot/icons/String.svg"
@onready var color_icon = "res://addons/datatable_godot/icons/Color.svg"
@onready var v2_icon = "res://addons/datatable_godot/icons/Vector2.svg"
@onready var v3_icon = "res://addons/datatable_godot/icons/Vector3.svg"
@onready var v4_icon = "res://addons/datatable_godot/icons/Vector4.svg"
@onready var bool_icon = "res://addons/datatable_godot/icons/bool.png"

@onready var arr_icon = "res://addons/datatable_godot/icons/array_value.png"
@onready var single_icon = "res://addons/datatable_godot/icons/single_value.png"

@onready var _shown = false

signal select_type(object_node: HBoxContainer)
signal remove_type(object_node: HBoxContainer)

signal recheck_param_name()
signal recheck_type_name()

signal edit_param_name_ask(param_name: String)
signal edit_param_name_response(valid: bool)

signal add_param_ask(param_name: String, param_type: int, param_size: int)
signal add_param_response(success: bool)

signal remove_param_ask(param_name: String)

signal check_type_name_ask(type_name: String)
signal check_type_name_response(valid: bool)

signal add_type_ask(type_name: String)
signal add_type_response(success: bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	## link this signal to get when the window is opened
	common.toggle_manageType_response.connect(_signal_onShown)
	
	## link this signal to get when the window is closed
	common.toggle_main_response.connect(_signal_onHide)
	
	## link this signal to get the script key once asked
	common.script_key_response.connect(_signal_key_response)
	
	common.script_key_ask.emit("bg_manageType")
	
	common.ask_reload_data.connect(check_data)
	
	## link this signal to get the types data once asked
	common.get_type_response.connect(_signal_type_response)
	
	## link this signal to check if param name is valid
	edit_param_name_ask.connect(_signal_edit_param_name)
	
	## link this signal to add a new param to the current selected type
	add_param_ask.connect(_signal_add_param)
	
	## link this signal to remove a param to the current selected type
	remove_param_ask.connect(_signal_remove_param)
	
	## link this signal to check if the type name is valid or not
	check_type_name_ask.connect(_signal_check_type_name)
	
	## link this signal to add a new type
	add_type_ask.connect(_signal_add_type)
	
	select_type.connect(_signal_select_type)
	remove_type.connect(_signal_remove_type)

func check_data():
	
	if _shown:
		common.get_type_ask.emit(script_key)

func _signal_onShown():
	common.get_type_ask.emit(script_key)
	_shown = true
	pass

func _signal_onHide():
	_shown = false
	pass

func _signal_key_response(key: int, script_name: String):
	if script_name == "bg_manageType":
		script_key = key

func _signal_type_response(types: Dictionary, key: int):
	if key == script_key:
		types_data = types
		
		reload_list()

func reload_list():
	
	if typeList.get_child_count() != 0:
		for child:Node in typeList.get_children():
			if child != schemaType:
				typeList.remove_child(child)
	
	for object_key: String in types_data:
		
		var object = types_data[object_key]
		var item_node: HBoxContainer = schemaType.duplicate()
		
		if selected_object_key == object_key:
			selected_object_node = item_node
			var text: RichTextLabel = selected_object_node.get_child(0)
			text.add_theme_color_override("default_color", get_theme_color("accent_color", "Editor"))
		
		typeList.add_child(item_node)
		
		item_node.get_child(0).text = object['name']
		item_node.set_meta('item_name', object['name'])
		item_node.set_meta('item_key', object_key)
		item_node.visible = true

func _signal_select_type(object_node: HBoxContainer):
	if object_node.has_meta('item_key'):
		var object_key = object_node.get_meta('item_key')
		var object = types_data[object_key]
		
		if selected_object_node != null:
			var text: RichTextLabel = selected_object_node.get_child(0)
			text.remove_theme_color_override("default_color")
		
		selected_object_key = object_key
		selected_object_node = object_node
		
		var text: RichTextLabel = selected_object_node.get_child(0)
		text.add_theme_color_override("default_color", get_theme_color("accent_color", "Editor"))
		
		for i:Node in paramList.get_children():
			if schemaParam == i:
				continue
			paramList.remove_child(i)
		
		for param_key: String in object['params']:
			var param: Dictionary = object['params'][param_key]
			
			var duplicate: HBoxContainer = schemaParam.duplicate()
			paramList.add_child(duplicate)
			
			var nSize = duplicate.get_child(0)
			var node = duplicate.get_child(1)
			
			var b_delete = duplicate.get_child(2)
			
			b_delete.set_meta('param_name', param['name'])
			
			var node_icon: String
			var node_size: String
			node.bbcode_enabled = true
			
			match int(param['type']):
				common.TYPE_STRING:
					node_icon = str_icon
				common.TYPE_FLOAT:
					node_icon = float_icon
				common.TYPE_COLOR:
					node_icon = color_icon
				common.TYPE_INT:
					node_icon = int_icon
				common.TYPE_VECTOR2:
					node_icon = v2_icon
				common.TYPE_VECTOR3:
					node_icon = v3_icon
				common.TYPE_VECTOR4:
					node_icon = v4_icon
				common.TYPE_BOOL:
					node_icon = bool_icon
			
			
			if !param.has("size"):
				param['size'] = 0
			
			if int(param['size']) == 0:
				node_size = single_icon
			else:
				node_size = arr_icon
			
			nSize.icon = load(node_size)
			node.text = str("[img]",node_icon,"[/img] ",param['name'])
			node.fit_content = true
			duplicate.visible = true
		
		recheck_param_name.emit()

func _signal_remove_type(object_node: HBoxContainer):
	if object_node.has_meta('item_key'):
		var object_key = object_node.get_meta('item_key')
		
		if types_data.has(object_key):
			types_data.erase(object_key)
			object_node.queue_free()
			if selected_object_key == object_key:
				for i:Node in paramList.get_children():
					if schemaParam == i:
						continue
					paramList.remove_child(i)
		recheck_param_name.emit()
		recheck_type_name.emit()
	common.save_in_ressource()
	pass

func _signal_edit_param_name(param_name: String):
	
	param_name = param_name.to_lower()
	
	if param_name.is_empty():
		edit_param_name_response.emit(false)
		return
	
	if selected_object_key == "":
		edit_param_name_response.emit(false)
		return
		
	if !types_data.has(selected_object_key):
		edit_param_name_response.emit(false)
		return
	
	if types_data[selected_object_key]['params'].has(param_name):
		edit_param_name_response.emit(false)
		return
	edit_param_name_response.emit(true)

func _signal_add_param(param_name: String, param_type: int, param_size: int):
	
	param_name = param_name.to_lower()
	
	if selected_object_key == "":
		add_param_response.emit(false)
		return
	
	if types_data[selected_object_key]['params'].has(param_name):
		add_param_response.emit(false)
		return
	
	types_data[selected_object_key]['params'][param_name] = {"name": param_name, "type": param_type, "size": param_size}
	
	add_param_response.emit(true)
	_signal_select_type(selected_object_node)
	common.save_in_ressource()

func _signal_remove_param(param_name: String):
	
	if selected_object_key == "":
		return
	
	if types_data[selected_object_key]['params'].has(param_name):
		types_data[selected_object_key]['params'].erase(param_name)
		_signal_select_type(selected_object_node)
	common.save_in_ressource()

func _signal_check_type_name(new_type: String):
	
	new_type = new_type.to_lower()
	
	if types_data.has(new_type):
		check_type_name_response.emit(false)
		return
	check_type_name_response.emit(true)

func _signal_add_type(new_type: String):
	
	new_type = new_type.to_lower()
	
	if types_data.has(new_type):
		add_type_response.emit(false)
		return
	
	if new_type.is_empty():
		add_type_response.emit(false)
		return
	
	types_data[new_type] = {"name": new_type, "params": {}}
	
	reload_list()
	
	add_type_response.emit(true)
	common.save_in_ressource()

