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
				
				var default = structure['params'][key]['default']
				
				if structure['params'][key]['size'] == 1:
					default = null
				
				set_data_on_struct(key, value, default)
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
		var default: Variant = null
		
		if param.has('default'):
			default = param['default']
		
		var schema = _dt_schema.get_instance().get_schema(type)
		
		if paramSize != 0:
			var parent = _dt_schema.get_instance().array_schema.instantiate()
			add_child(parent)
			add_child(separator)
			
			parent.set_type(type)
			parent.set_title(title)
			var name_node = parent.get_child(0).get_child(0)
			
			name_node.set_tooltip_text(comment)
			node_structure[key] = parent
			
			parent.visible = true
			
			continue
		
		var object: Node = schema.instantiate()
		
		add_child(object) ## adding it to the VBox
		
		object.set_value(default)
		
		add_child(separator)
		
		node_structure[key] = object
		
		object.set_title(title)
		
		var name_node = object.get_child(0)
		name_node.set_tooltip_text(comment)
		
		object.visible = true

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
	

func set_data_on_struct(key: String, data: Variant, default: Variant = null):
	
	if node_structure.has(key):
		var node:Node = node_structure.get(key)
		
		if data != null:
			node.set_value(data)
			return
		
		node.set_value(default)

func reset_data_on_struct():
	
	for i:String in node_structure:
		var node: Node = node_structure[i]
		
		node.set_value()
