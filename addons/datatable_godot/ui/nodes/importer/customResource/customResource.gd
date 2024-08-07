@tool
extends Window

signal vars_selected(vars: Array)

signal vars_deselect(except_name: String)
signal vars_block(except_name: String)
signal vars_unblock()

# Variable that stores the var inside the given resource
var var_list_data = []
var var_fix_data = []


# Search box
@onready var le_search: LineEdit = %le_search
@onready var bt_search: Button = %bt_search

# List of vars
@onready var var_list: VBoxContainer = %var_list
var var_list_model: Resource

# label amount selected
@onready var label_selected: Label = %lbl_amount

# confirm button
@onready var bt_select: Button = %bt_select

var total_amount = 0:
	set(new_amount):
		total_amount = new_amount
		label_selected.text = "Amount selected: " + str(selected_amount) + "/" + str(total_amount)

var selected_amount = 0:
	set(new_amount):
		selected_amount = new_amount
		label_selected.text = "Amount selected: " + str(selected_amount) + "/" + str(total_amount)

func _ready():
	var_list_model = preload("res://addons/datatable_godot/ui/nodes/importer/customResource/customResourceVarListItem.tscn")

	# Connect the signals
	bt_search.pressed.connect(_on_bt_search_pressed)
	bt_select.pressed.connect(_on_bt_select_pressed)
	
	# Connect the close signal
	close_requested.connect(_on_close)

func _add_item(var_name: String, var_type: int, valid: bool = true, add_to_var: bool = true):
	var item = var_list_model.instantiate()

	item.var_name = var_name
	item.var_type = str(var_type)
	item.var_valid = valid
	print("var_name: ", var_name, " - var_type: ", var_type, " - valid: ", valid)

	item.var_import_changed.connect(_on_item_selected)
	vars_deselect.connect(item._on_deselect)
	vars_block.connect(item._on_block)
	vars_unblock.connect(item._on_unblock)

	var_list.add_child(item)
	var_list_data.append(item)
	if add_to_var:
		var_fix_data.append({"name": var_name, "type": var_type, "valid": valid})
		total_amount += 1
	print("_add_item: ", var_name, " - ", var_type)
	print("\n\tvar_list_data: ", var_list_data)

func clear_items_ui():
	for i in var_list.get_children():
		i.queue_free()

func clear_items_data():
	var_list_data.clear()
	total_amount = 0

func _get_vars(search_text: String) -> Array:
	var vars = []

	# Get the vars
	for i in var_fix_data:
		var var_name = i.name
		var var_type = i.type
		var var_valid = i.valid

		# Check if the var name contains the search text
		if search_text == "" or var_name.find(search_text) != -1:
			vars.append({"name": var_name, "type": var_type, "valid": var_valid})

	return vars

func _on_bt_search_pressed():
	# Clear the list
	clear_items_ui()

	# Get the search text
	var search_text = le_search.text

	# Get the vars
	var vars = _get_vars(search_text)

	clear_items_data()
	# Add the vars to the list
	for v in vars:
		_add_item(v.name, v.type, v.valid, false)

func _on_bt_select_pressed():

	# Get the selected vars
	var selected_vars = []

	for i in var_list_data:
		if i.var_import:
			selected_vars.append({"name": i.var_name, "type": i.var_type, "valid": i.var_valid})

	# Emit the signal
	vars_selected.emit(selected_vars)

	print("close window")

func _on_close():
	# Emit the signal
	vars_selected.emit([])

	print("close window")

	queue_free()

func _on_item_selected(var_name: String, var_import: bool, var_type: String):
	print("var_name: ", var_name, " - var_import: ", var_import)

	# Update the selected amount
	if var_import:
		selected_amount += 1
	else:
		selected_amount -= 1
		if selected_amount < 0:
			selected_amount = 0
	
	# Check if the selected item is a dict
	if var_type.to_int() == TYPE_DICTIONARY:
		if !var_import:
			vars_unblock.emit()
			return
		vars_deselect.emit(var_name)
		vars_block.emit(var_name)
		selected_amount = 1
		return

	