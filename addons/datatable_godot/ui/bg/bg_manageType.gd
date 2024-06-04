@tool
extends Panel

@onready var common: Node = %signals

@onready var script_key: int = -1

@onready var types_data: Dictionary = {}
@onready var tables_data: Dictionary = {}

@onready var b_addParam: Button = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/HBoxContainer/b_add_param

@onready var typeList: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer
@onready var paramList: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/Panel/MarginContainer/ScrollContainer/VBoxContainer

@onready var schemaType: HBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer/schema_type
@onready var schemaParam: VBoxContainer = $VBoxContainer/HBoxContainer/VBoxContainer2/VSplitContainer/VBoxContainer2/Panel/MarginContainer/ScrollContainer/VBoxContainer/VBoxContainer

@onready var selected_object_key: String = ""
@onready var selected_object_node: Node

@onready var _shown = false

var _default_box_list = []

signal select_type(object_node: HBoxContainer)
signal remove_type(object_node: HBoxContainer)
signal generate_class(object_node: HBoxContainer)

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
	
	_dt_resource.get_instance().res_reload.connect(check_data)
	
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
	generate_class.connect(_on_generate_class)

func check_data():
	
	if _shown:
		get_type()
		get_data()

func _signal_onShown():
	get_type()
	get_data()
	
	_shown = true
	pass

func _signal_onHide():
	_shown = false
	for i:Node in paramList.get_children():
		if schemaParam == i:
			continue
		paramList.remove_child(i)
	
	
	if !selected_object_key.is_empty():
		save_default(selected_object_key)
	
	if selected_object_node != null:
		var text: RichTextLabel = selected_object_node.get_child(0)
		text.remove_theme_color_override("default_color")
	selected_object_node = null
	selected_object_key = ""
	pass

func get_type():
	types_data = _dt_resource.get_instance().get_type()
	
	reload_list()

func get_data():
	tables_data = _dt_resource.get_instance().get_data()

func save_default(object_key: String):
	
	if _default_box_list.size() == 0:
		return
	
	for i: Node in _default_box_list:
		
		if !i.has_meta('key') || !i.has_meta('node'):
			continue
		
		var key = i.get_meta('key')
		var input = i.get_meta('node')
		
		var type = types_data[object_key]
		
		if key.is_empty() || !input:
			continue
		
		if !type['params'].has(key):
			continue
		
		type['params'][key]['default'] = input.get_value()

func reload_list():
	
	if !selected_object_key.is_empty():
		save_default(selected_object_key)
	
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
	
	if !selected_object_key.is_empty():
		save_default(selected_object_key)
	
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
			
			var duplicate: VBoxContainer = schemaParam.duplicate()
			paramList.add_child(duplicate)
			
			var nSize = duplicate.get_child(0).get_child(0)
			var node = duplicate.get_child(0).get_child(1)
			
			var b_delete = duplicate.get_child(0).get_child(2)
			
			var in_comment: LineEdit = duplicate.get_child(1).get_child(1).get_child(0).get_child(1)
			
			b_delete.set_meta('param_name', param['name'])
			
			if !param.has('comment'):
				param['comment'] = str(param['name']," parameter...")
			
			in_comment.set_text(param['comment'])
			
			in_comment.text_changed.connect(_on_change_param_comment.bind(param['name']))
			
			var node_icon: String
			var node_size: String
			node.bbcode_enabled = true
			
			node_icon = _dt_schema.get_instance().get_icon(param['type'])
			
			var allow_default: bool = true
			
			if !param.has("size"):
				param['size'] = 0
			
			if int(param['size']) == 0:
				node_size = _dt_common.SINGLE_ICON
			else:
				node_size = _dt_common.ARR_ICON
				allow_default = false
			
			nSize.icon = load(node_size)
			node.text = str("[img]",node_icon,"[/img] ",param['name'])
			node.fit_content = true
			
			if allow_default:
				var default_node_ress = _dt_schema.get_instance().get_schema(param['type'])
				var default_node = default_node_ress.instantiate()
				
				var default_box = HBoxContainer.new()
				
				var margin: MarginContainer = MarginContainer.new()
				margin.custom_minimum_size = Vector2(24, 0)
				
				var default_label: Label = Label.new()
				default_label.set_text("Default:")
				default_label.custom_minimum_size = Vector2(85, 0)
				
				default_box.add_child(margin)
				default_box.add_child(default_label)
				default_box.add_child(default_node)
				
				default_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				default_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				duplicate.add_child(default_box)
				
				default_node.get_child(0).visible = false
				default_node.set_title("Default value")
				default_box.set_meta('key', param['name'])
				default_box.set_meta('node', default_node)
				
				if !param.has('default'):
					param['default'] = ""
				
				default_node.set_value(param['default'])
				_default_box_list.append(default_box)
				
				default_node.visible = true
			
			var bottom_separator = MarginContainer.new()
			bottom_separator.custom_minimum_size = Vector2(10, 10)
			
			duplicate.add_child(bottom_separator)
			
			
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
	
	_dt_resource.get_instance().save_file()
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

func _on_change_param_comment(param_content: String, param_name: String):
	
	param_name = param_name.to_lower()
	
	if param_name.is_empty():
		return
	
	if selected_object_key == "":
		return
	
	if !types_data.has(selected_object_key):
		return
	
	if !types_data[selected_object_key]['params'].has(param_name):
		return
	
	types_data[selected_object_key]['params'][param_name]['comment'] = param_content

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
	_dt_resource.get_instance().save_file()

func _signal_remove_param(param_name: String):
	
	if selected_object_key == "":
		return
	
	if types_data[selected_object_key]['params'].has(param_name):
		types_data[selected_object_key]['params'].erase(param_name)
		_signal_select_type(selected_object_node)
		
	for i in tables_data.keys():
		if tables_data[i]['structure'] == selected_object_key:
			for row_key in tables_data[i]['rows'].keys():
				if tables_data[i]['rows'][row_key]['columns'].has(param_name):
					tables_data[i]['rows'][row_key]['columns'].erase(param_name)
	
	_dt_resource.get_instance().save_file()

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
	_dt_resource.get_instance().save_file()

func _on_generate_class(object_node: HBoxContainer):
	var object_key = object_node.get_meta('item_key')
	var object = types_data[object_key]
	
	var code_content = _dt_class_generator.get_instance().generate(object)
	
	var preview_window: ConfirmationDialog = load("res://addons/datatable_godot/ui/nodes/generatedClassPreview/generatedClassPreview.tscn").instantiate()                                          
	
	EditorInterface.get_base_control().add_child(preview_window)
	
	preview_window.content = code_content
	preview_window.className = object['name']
	
	preview_window.visible = true
