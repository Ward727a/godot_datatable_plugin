@tool
extends MenuButton

signal csv_selected(content: String)

signal cr_selected(res: Resource)

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

	_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_dialog.min_size = Vector2(600, 400)
	_dialog.filters = ["*.csv ; CSV file"]

	_dialog.file_selected.connect(_on_csv_selected)

	get_parent().add_child(_dialog)

	_dialog.popup_centered()

func _on_item_CR_pressed():
	print("CR pressed")

	var _dialog = FileDialog.new()

	_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_dialog.min_size = Vector2(600, 400)
	_dialog.filters = ["*.tres ; Resource file", "*.res ; Binary resource file"]

	_dialog.file_selected.connect(_on_cr_selected)

	get_parent().add_child(_dialog)

	_dialog.popup_centered()


func _on_csv_selected(path):
	print("CSV selected")

	var file = FileAccess.open(path, FileAccess.READ)

	if !file:
		print("Error opening file")
		return
	
	var content = file.get_as_text()
	print(content)
	file.close()

	csv_selected.emit(content)

func _on_cr_selected(path):
	print("CR selected")

	var res = ResourceLoader.load(path)

	if !res:
		print("Error loading resource")
		return

	cr_selected.emit(res)


