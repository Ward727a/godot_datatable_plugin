@tool
extends HBoxContainer

var tableItemName: RichTextLabel
var itemName: String

var item_delete: Button

signal item_pressed(item_node: Node)
signal item_deleted(item_node: Node)

var common
var table_name

# Called when the node enters the scene tree for the first time.
func _ready():
	
	tableItemName = get_child(0)
	item_delete = get_child(1).get_child(0)
	
	tableItemName.pressed.connect(_item_pressed_on)
	
	pass # Replace with function body.

func set_title(new_value: String):
	tableItemName.common = common
	tableItemName.table_name = table_name
	itemName = new_value
	tableItemName.set_text(new_value)
	item_delete.pressed.connect(_delete_event)

func set_data(data: Dictionary):
	set_meta("item_data", data)

func has_data():
	return has_meta("item_data")

func get_data():
	return get_meta('item_data')

func get_title():
	return itemName

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _delete_event():
	item_deleted.emit(self)

func _item_pressed_on():
	item_pressed.emit(self)

func select(toggle: bool):
	
	if tableItemName == null:
		return
	
	if toggle:
		tableItemName.add_theme_color_override("default_color", get_theme_color("accent_color", "Editor"))
	else:
		tableItemName.remove_theme_color_override("default_color")
