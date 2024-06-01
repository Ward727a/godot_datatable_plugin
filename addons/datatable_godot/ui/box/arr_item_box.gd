@tool
extends VBoxContainer

@onready var COMMON: Node = $"../../../../../../../../../../../../signals"

var data = {}

var used_schema: Resource = null
@onready var item_schema: HBoxContainer = get_child(0)

func add_item(value: Variant):
	
	var item_name = data.size()
	
	if data.has(item_name):
		return
	
	if used_schema == null:
		return
	
	var item = item_schema.duplicate()
	add_child(item)
	var duplicate = used_schema.instantiate()
	item.add_child(duplicate)
	item.move_child(duplicate, 0)
	duplicate.set_value(value)
	
	var b_delete = item.get_child(1)
	
	b_delete.pressed.connect(remove_item.bind(item_name))
	
	duplicate.set_h_size_flags(SIZE_EXPAND_FILL)
	
	data[item_name] = {'value':value, 'node': duplicate, "item": item}
	
	duplicate.set_disabled(true)
	
	# Hide text node
	duplicate.text.visible = false
	
	duplicate.visible = true
	item.visible = true

func remove_item(item_name: int):
	
	if !data.has(item_name):
		printerr("Data doesn't have ",item_name)
		return
	
	var node: Node = data[item_name]['item']
	
	data.erase(item_name)
	
	node.queue_free()
	
	COMMON.presave_data.emit()
	

func get_items_value()->String:
	
	var arr: String = " ARR/ "
	
	for i in data:
		if data[i].has('value'):
			if typeof(data[i]['value']) == TYPE_STRING:
				data[i]['value'] = data[i]['value'].replace(';', '')
			
			arr += str(data[i]['value'])
			if (data.size()-1) > i:
				arr += ";"
	
	
	return arr

func reset_items():
	
	for i in data.size():
		data[i]['item'].queue_free()
	data = {}
