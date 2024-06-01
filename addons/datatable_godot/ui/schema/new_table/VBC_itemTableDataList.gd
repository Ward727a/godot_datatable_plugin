@tool
extends VBoxContainer

@onready var common = %signals



@onready var data: Dictionary = {}

@onready var OB_TableType: OptionButton = $"../../../../../VBoxContainer/param_block/MarginContainer/VBoxContainer/table_type_box/OB_tableType"

@onready var structure: Dictionary = {}

@onready var node_structure:Dictionary = {}

signal save_data(data_to_save: Dictionary)


func _clean(remove_form: bool):
	
	save_data.emit(data)
	
	if remove_form:
		for i: Node in get_children():
			i.queue_free()
		
		structure = {}
	
	data = {}

func reload(new_data: Dictionary):
	
	save_data_of_struct()
	
	var struct = OB_TableType.get_selected_metadata()
	
	if structure == struct:
		_clean(false)
	else:
		_clean(true)
	
	data = new_data
	
	if struct == null:
		common.popup_alert_ask.emit("Can't open this data", "The plugin can't load this data because the structure of the table is not found!")
		return
		
	reload_from_struct(struct)
	
	if data.has('columns'):
		var columns: Dictionary = data['columns']
		
		if columns.size() != 0:
			for i in columns:
				var data: Dictionary = columns[i]
				var value: Variant = data['value']
				var key: String = data['name']
				
				set_data_on_struct(key, value)
		else:
			reset_data_on_struct()
			save_data_of_struct()

func reload_from_struct(struct: Dictionary):
	
	if structure == struct:
		return
	
	structure = struct
	node_structure = {}
	
	for key: String in struct['params']:
		var separator = MarginContainer.new()
		separator.add_theme_constant_override("margin_top",5)
		var param: Dictionary = struct['params'][key]
		
		var type: int = param['type']
		var title: String = param['name']
		var paramSize: int = param['size']
		var comment: String = param['comment']
		
		var schema
		
		match(type):
			_dt_common.TYPE_STRING:
				schema = _dt_schema.get_instance().string_schema
			_dt_common.TYPE_INT:
				schema = _dt_schema.get_instance().int_schema
			_dt_common.TYPE_FLOAT:
				schema = _dt_schema.get_instance().float_schema
			_dt_common.TYPE_COLOR:
				schema = _dt_schema.get_instance().color_schema
			_dt_common.TYPE_VECTOR2:
				schema = _dt_schema.get_instance().vector2_schema
			_dt_common.TYPE_VECTOR3:
				schema = _dt_schema.get_instance().vector3_schema
			_dt_common.TYPE_VECTOR4:
				schema = _dt_schema.get_instance().vector4_schema
			_dt_common.TYPE_BOOL:
				schema = _dt_schema.get_instance().bool_schema
			_dt_common.TYPE_RESS:
				schema = _dt_schema.get_instance().ress_schema
			_dt_common.TYPE_QUAT:
				schema = _dt_schema.get_instance().quat_schema
			_dt_common.TYPE_RECT:
				schema = _dt_schema.get_instance().rect_schema
			_dt_common.TYPE_PLANE:
				schema = _dt_schema.get_instance().plane_schema
			_dt_common.TYPE_T2:
				schema = _dt_schema.get_instance().t2_schema
			_dt_common.TYPE_T3:
				schema = _dt_schema.get_instance().t3_schema
			_dt_common.TYPE_AABB:
				schema = _dt_schema.get_instance().aabb_schema
			_dt_common.TYPE_BASIS:
				schema = _dt_schema.get_instance().basis_schema
			_dt_common.TYPE_PROJ:
				schema = _dt_schema.get_instance().proj_schema
		
		if paramSize != 0:
			var parent = _dt_schema.get_instance().array_schema.duplicate()
			add_child(parent)
			add_child(separator)
			
			parent.set_type(type)
			parent.set_title(title)
			var name_node = parent.get_child(0).get_child(0)
			
			name_node.set_tooltip_text(comment)
			node_structure[key] = parent
			
			parent.visible = true
			
			continue
		
		var duplicate: Node = schema.duplicate()
		
		
		add_child(duplicate)
		
		add_child(separator)
		
		node_structure[key] = duplicate
		
		duplicate.set_title(title)
		
		var name_node = duplicate.get_child(0)
		name_node.set_tooltip_text(comment)
		
		duplicate.visible = true

func save_data_of_struct():
	
	if structure == {}:
		return
	
	for i: String in node_structure:
		
		if !structure['params'].has(i):
			return
		
		var node: Node = node_structure[i]
		var struct_data: Dictionary = structure['params'][i]
		
		if !data['columns'].has(i):
			data['columns'][i] = {}
		
		
		data['columns'][i]['name'] = struct_data['name']
		data['columns'][i]['type'] = struct_data['type']
		data['columns'][i]['value'] = node.get_value()
		data['columns'][i]['size'] = struct_data['size']
	

func set_data_on_struct(key: String, data: Variant):
	
	if node_structure.has(key):
		var node:Node = node_structure.get(key)
		
		node.set_value(data)

func reset_data_on_struct():
	
	for i:String in node_structure:
		var node: Node = node_structure[i]
		
		node.set_value()
