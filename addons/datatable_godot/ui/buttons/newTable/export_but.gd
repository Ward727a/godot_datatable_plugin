@tool
extends MenuButton

signal csv_export(path: String)

signal cr_export(path: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# link id_pressed signal to _on_pressed_id function
	get_popup().id_pressed.connect(_on_item_pressed)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_disabled(disabled: bool):
	self.disabled = disabled

func _on_item_pressed(item_id: int):
	print("Item pressed")

	match(item_id):
		0:
			_on_item_csv_pressed()
		1:
			_on_item_CR_pressed()
		_:
			print("Unknown item pressed")

func _on_item_csv_pressed():
	print("CSV pressed")

	var _dialog = FileDialog.new()

	_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_dialog.min_size = Vector2(600, 400)
	_dialog.filters = ["*.csv ; CSV file"]

	_dialog.file_selected.connect(_on_csv_selected)

	get_parent().add_child(_dialog)

	_dialog.popup_centered()

func _on_item_CR_pressed():
	print("CR pressed")

	var _dialog = FileDialog.new()

	_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_dialog.min_size = Vector2(600, 400)
	_dialog.filters = ["*.tres ; Resource file", "*.res ; Binary resource file"]

	_dialog.file_selected.connect(_on_cr_selected)

	get_parent().add_child(_dialog)

	_dialog.popup_centered()


func _on_csv_selected(path):
	print("CSV selected")

	csv_export.emit(path)

func _on_cr_selected(path):
	print("CR selected")

	

	cr_export.emit(path)


