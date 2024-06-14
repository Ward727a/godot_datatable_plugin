@tool
extends MenuButton

signal csv_selected(content: String)

signal cr_selected(res: Resource, type_selected_name: String)

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
	var resource_types = _dt_classDB.get_direct_child("Resource")

	print(resource_types)

	var option_box = HBoxContainer.new()
	

	var option_label = Label.new()
	option_label.text = "Resource type: "

	var option_button = OptionButton.new()
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var options = []

	for i in resource_types:
		options.append(i)
	
	options.sort()

	for i in options:
		option_button.add_item(i)

	option_box.add_child(option_label)
	option_box.add_child(option_button)

	_dialog.get_vbox().add_child(option_box) # add type selection to file dialog

	_dialog.file_selected.connect(_on_cr_selected.bind(option_button))

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

func _on_cr_selected(path, option_button):
	print("CR selected")

	var res = ResourceLoader.load(path)

	if !res:
		print("Error loading resource")
		return

	cr_selected.emit(res, option_button.get_item_text(option_button.selected))


