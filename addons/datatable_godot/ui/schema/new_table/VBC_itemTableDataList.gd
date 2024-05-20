@tool
extends VBoxContainer

@onready var common = %signals

@onready var string_schema
@onready var bool_schema
@onready var int_schema
@onready var float_schema
@onready var color_schema
@onready var vector2_schema
@onready var vector3_schema
@onready var vector4_schema

@onready var array_schema

@onready var data: Dictionary = {}

@onready var OB_TableType: OptionButton = $"../../../../../VBoxContainer/param_block/MarginContainer/VBoxContainer/table_type_box/OB_tableType"

@onready var structure: Dictionary = {}

@onready var node_structure:Dictionary = {}

signal save_data(data_to_save: Dictionary)

# Called when the node enters the scene tree for the first time.
func _ready():
	string_schema = get_child(0)
	int_schema = get_child(1)
	float_schema = get_child(2)
	color_schema = get_child(3)
	vector2_schema = get_child(4)
	vector3_schema = get_child(5)
	vector4_schema = get_child(6)
	array_schema = get_child(7)
	bool_schema = get_child(8)
	pass # Replace with function body.

func get_each():
	var each = [string_schema, int_schema, float_schema, color_schema, vector2_schema, vector3_schema, vector4_schema, array_schema, bool_schema]
	
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
		var param: Dictionary = struct['params'][key]
		
		var type: int = param['type']
		var title: String = param['name']
		var paramSize: int = param['size']
		
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
		
		if paramSize != 0:
			var parent = array_schema.duplicate()
			add_child(parent)
			
			parent.set_type(type)
			parent.set_title(title)
			node_structure[key] = parent
			
			parent.visible = true
			
			continue
		
		var duplicate: Node = schema.duplicate()
		
		add_child(duplicate)
		
		node_structure[key] = duplicate
		
		duplicate.set_title(title)
		
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
