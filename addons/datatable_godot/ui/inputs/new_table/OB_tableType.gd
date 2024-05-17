@tool
extends OptionButton

@onready var bg_newTable: Panel = $"../../../../../../../.."

func _ready():
	bg_newTable.reload_table_type_options_ask.connect(_reload_option_ask)
	item_selected.connect(_signal_item_selected)
	pass
	



func _reload_option_ask(new_options: Dictionary):
	
	var old_selected_id: int = get_selected_id()
	var old_selected_text: String = get_item_text(old_selected_id) if old_selected_id != -1 else ""
	
	
	if old_selected_id == -1:
		old_selected_id = 0
	
	clear()
	
	for i:String in new_options:
		add_item(i)
		set_item_metadata((item_count-1), new_options[i])
	
	if item_count != 0:
		select(old_selected_id)
		if old_selected_text != get_item_text(old_selected_id):
			select(0)

func _signal_item_selected(id: int):
	bg_newTable.change_table_type.emit(id)
	set_tooltip_text(get_item_metadata(id)['name'])

func set_to_type(type_name: String):
	for i in item_count:
		if i == item_count:
			return false
		
		if get_item_metadata(i)['name'] == type_name:
			select(i)
			set_tooltip_text(type_name)
			return true
