@tool
extends VBoxContainer

@onready var common = %signals

@onready var string_schema = $string_schema
@onready var bool_schema = $bool_schema
@onready var int_schema = $int_schema
@onready var float_schema = $float_schema
@onready var color_schema = $color_schema
@onready var vector2_schema = $vector2_schema
@onready var vector3_schema = $vector3_schema
@onready var vector4_schema = $vector4_schema
@onready var ress_schema = $ress_schema
@onready var quat_schema = $quat_schema
@onready var rect_schema = $rect_schema
@onready var plane_schema = $plane_schema
@onready var t2_schema = $t2_schema
@onready var t3_schema = $t3_schema
@onready var aabb_schema = $aabb_schema
@onready var basis_schema = $basis_schema
@onready var proj_schema = $proj_schema

@onready var array_schema = $array_schema

@onready var data: Dictionary = {}

@onready var OB_TableType: OptionButton = $"../../../../../VBoxContainer/param_block/MarginContainer/VBoxContainer/table_type_box/OB_tableType"

@onready var structure: Dictionary = {}

@onready var node_structure:Dictionary = {}

signal save_data(data_to_save: Dictionary)

func get_each():
	var each = [
		string_schema,
		int_schema,
		float_schema,
		color_schema,
		vector2_schema,
		vector3_schema,
		vector4_schema,
		array_schema,
		bool_schema,
		ress_schema,
		quat_schema,
		rect_schema,
		plane_schema,
		t2_schema,
		t3_schema,
		aabb_schema,
		basis_schema,
		proj_schema
	]
	
	return each

func _clean(remove_form: bool):
	
	save_data.emit(data)
	
	if remove_form:
		for i: Node in get_children():
			if !get_each().has(i):
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
			common.TYPE_STRING:
				schema = string_schema
			common.TYPE_INT:
				schema = int_schema
			common.TYPE_FLOAT:
				schema = float_schema
			common.TYPE_COLOR:
				schema = color_schema
			common.TYPE_VECTOR2:
				schema = vector2_schema
			common.TYPE_VECTOR3:
				schema = vector3_schema
			common.TYPE_VECTOR4:
				schema = vector4_schema
			common.TYPE_BOOL:
				schema = bool_schema
			common.TYPE_RESS:
				schema = ress_schema
			common.TYPE_QUAT:
				schema = quat_schema
			common.TYPE_RECT:
				schema = rect_schema
			common.TYPE_PLANE:
				schema = plane_schema
			common.TYPE_T2:
				schema = t2_schema
			common.TYPE_T3:
				schema = t3_schema
			common.TYPE_AABB:
				schema = aabb_schema
			common.TYPE_BASIS:
				schema = basis_schema
			common.TYPE_PROJ:
				schema = proj_schema
		
		if paramSize != 0:
			var parent = array_schema.duplicate()
			add_child(parent)
			add_child(separator)
			
			parent.set_type(type)
			parent.set_title(title)
			node_structure[key] = parent
			
			parent.visible = true
			
			continue
		
		var duplicate: Node = schema.duplicate()
		
		
		add_child(duplicate)
		
		add_child(separator)
		
		node_structure[key] = duplicate
		
		duplicate.set_title(title)
		
		var name_node
		if paramSize == 0:
			name_node = duplicate.get_child(0)
		else:
			name_node = duplicate.get_child(0).get_child(0)
		
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
