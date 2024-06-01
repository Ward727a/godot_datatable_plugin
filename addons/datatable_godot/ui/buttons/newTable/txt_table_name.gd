@tool
extends RichTextLabel

@onready var bg_newTable: Panel = $"../../../../../../.."

var common

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			bg_newTable.select_table.emit(get_parent())
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			copy_template_code()

func copy_template_code():
	
	var label: Label = Label.new()
	var timer: Timer = Timer.new()
	
	timer.one_shot = true
	timer.wait_time = 3.
	
	label.set_text("Template copied!")
	
	label.position = bg_newTable.get_local_mouse_position()
	
	label.position.y += 10
	label.position.x += 10
	
	timer.timeout.connect(_hide_text.bind(label, timer))
	bg_newTable.add_child(label)
	bg_newTable.add_child(timer)
	timer.start()
	
	var template = str(
		"\n",
		"const collection_path: String = \"",_dt_resource.get_instance().get_path(),"\"\n",
		"var collec: Collection = Collection.new(collection_path)\n",
		"\n",
		"const table_name: String = \"",get_text(),"\"\n",
		"var table: Datatable = collec.get_table(table_name)\n",
		"\n",
		"# Here you can start to get your item with the 'table' var\n"
	)
	
	DisplayServer.clipboard_set(template)

func _hide_text(label: Label, timer: Timer):
	label.queue_free()
	timer.queue_free()
