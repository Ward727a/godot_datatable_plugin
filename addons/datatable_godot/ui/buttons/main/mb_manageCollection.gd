@tool
extends MenuButton

@onready var common = %signals

var _popup_menu: PopupMenu

var _load_file_dialog: FileDialog
var _new_file_dialog: FileDialog

enum _MenuOption{
	LOAD_COLLECTION,
	NEW_COLLECTION
}

const _collection_required_key = ["table", "type"]

const _collection_file_filters: PackedStringArray = ["*.tableCollection.res ; Collection", "*.res ; Old collection"]
const _file_min_size: Vector2 = Vector2(450, 350)
const _file_initial_pos: Window.WindowInitialPosition = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN

# Called when the node enters the scene tree for the first time.
func _ready():
	_popup_menu = get_popup()
	
	_popup_menu.id_pressed.connect(_item_pressed)
	
	pass # Replace with function body.

func _item_pressed(id: int):
	
	match (id):
		_MenuOption.LOAD_COLLECTION: # Show load file popup
			
			_load_file_dialog = FileDialog.new()
			_load_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			
			_load_file_dialog.filters = _collection_file_filters
			_load_file_dialog.initial_position = _file_initial_pos
			_load_file_dialog.min_size = _file_min_size
			
			_load_file_dialog.visible = true
			
			EditorInterface.get_base_control().add_child(_load_file_dialog)
			
			_load_file_dialog.file_selected.connect(_on_load_collection)
			_load_file_dialog.close_requested.connect(_on_close_load)
			
			pass
		_MenuOption.NEW_COLLECTION: # Show create file popup
			
			_new_file_dialog = FileDialog.new()
			_new_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			
			_new_file_dialog.add_filter("*.tableCollection.res", "Collection")
			_new_file_dialog.initial_position = _file_initial_pos
			_new_file_dialog.min_size = _file_min_size
			
			_new_file_dialog.visible = true
			
			EditorInterface.get_base_control().add_child(_new_file_dialog)
			
			_new_file_dialog.file_selected.connect(_on_new_collection)
			_new_file_dialog.close_requested.connect(_on_close_new)
			
			pass

func _on_load_collection(collection_path: String):
	print_rich("[color=ffde66][DataTable] Loading collection at path: ", collection_path)
	
	var collections_name
	
	if collection_path.ends_with(".tableCollection.res"):
		collections_name = collection_path.split(".tableCollection.res")[0].split("/")
	else:
		collections_name = collection_path.split(".res")[0].split("/")
	
	var collection_name = collections_name[collections_name.size()-1]
	
	if !FileAccess.file_exists(collection_path):
		push_error("This file doesn't exist!")
		return
	
	var packedData = load(collection_path)
	
	if packedData.get_class() != "PackedDataContainer":
		push_error("This file is not of the class \"PackedDataContainer\"!")
		return
	
	var success_key: int = 0
	
	for i in packedData:
		if _collection_required_key.has(i):
			success_key += 1
	
	if success_key != _collection_required_key.size():
		push_error("This file doesn't have the required key to be an valid collection!")
		return
	
	print_rich("[color=lightgreen][DataTable] Loaded collection '",collection_name,"' with success!")
	
	common.table_datas = {}
	common.table_types = {}
	
	common.collection_path = collection_path
	common.ask_reload_data.emit()
	
	%label_collection.set_text(str("Opened collection: ", collection_name))
	%label_collection.set_tooltip_text(str("path: ",collection_path))
	
	_load_file_dialog.queue_free()

func _on_new_collection(collection_path: String):
	print_rich("[color=ffde66][DataTable] Creating new collection at path: ", collection_path)
	
	var collections_name
	
	if collection_path.ends_with(".tableCollection.res"):
		collections_name = collection_path.split(".tableCollection.res")[0].split("/")
	else:
		collections_name = collection_path.split(".res")[0].split("/")
	
	var collection_name = collections_name[collections_name.size()-1]
	
	var packedData: PackedDataContainer = PackedDataContainer.new()
	
	var template_data = {"table": {}, "type": {}}
	
	packedData.pack(template_data)
	
	var ret = ResourceSaver.save(packedData, collection_path)
	
	if ret != OK:
		push_error("Can't create collection due to an error when trying to save it!")
		return
	
	common.table_datas = {}
	common.table_types = {}
	
	common.collection_path = collection_path
	common.ask_reload_data.emit()
	
	print_rich("[color=lightgreen][DataTable] Created collection '",collection_name,"' with success!")
	
	%label_collection.set_text(str("Opened collection: ", collection_name))
	%label_collection.set_tooltip_text(str("path: ",collection_path))
	
	_new_file_dialog.queue_free()

func _on_close_load():
	_load_file_dialog.queue_free()

func _on_close_new():
	_new_file_dialog.queue_free()
