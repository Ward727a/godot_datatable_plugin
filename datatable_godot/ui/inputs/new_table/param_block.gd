@tool
extends Panel

@onready var bg_newTable: Panel = $"../../../.."
@onready var table_name_txt: Label = $MarginContainer/VBoxContainer/table_name_box/box_value
@onready var table_size_txt: Label = $MarginContainer/VBoxContainer/table_number_box/box_value
@onready var table_type_ob: OptionButton = $MarginContainer/VBoxContainer/table_type_box/OB_tableType

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reload(new_data: Dictionary):
	
	visible = true
	
	table_name_txt.set_text(new_data['name'])
	table_size_txt.set_text(str(new_data['size']))
	
	if new_data['size'] != 0:
		table_type_ob.disabled = true
	else:
		table_type_ob.disabled = false
	
	return table_type_ob.set_to_type(str(new_data['structure']))
