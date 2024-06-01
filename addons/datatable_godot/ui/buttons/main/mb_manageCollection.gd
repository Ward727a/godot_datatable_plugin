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
	print_rich("[color=",_dt_common.txt_color.WARNING,"][DataTable] Loading collection at path: ", collection_path)
	
	_dt_resource.get_instance().load_file(collection_path)
	_dt_resource.get_instance().res_reload.emit()
	
	var collection_name = _dt_resource.get_instance().get_name()
	collection_path = _dt_resource.get_instance().get_path()
	
	print_rich("[color=",_dt_common.txt_color.SUCCESS,"][DataTable] Loaded collection '",collection_name,"' with success!")
	
	%label_collection.set_text(str("Opened collection: ", collection_name))
	%label_collection.set_tooltip_text(str("path: ",collection_path))
	
	_dt_backup.get_instance().make(collection_path)
	
	_dt_backup.get_instance().link(%backup_timer, collection_path)
	
	$"../b_newTable".disabled = false
	$"../b_manageTableType".disabled = false
	
	_load_file_dialog.queue_free()

func _on_new_collection(collection_path: String):
	print_rich("[color=",_dt_common.txt_color.WARNING,"][DataTable] Creating new collection at path: ", collection_path)
	
	_dt_resource.get_instance().new_file(collection_path)
	_dt_resource.get_instance().res_reload.emit()
	
	var collection_name = _dt_resource.get_instance().get_name()
	collection_path = _dt_resource.get_instance().get_path()
	
	print_rich("[color=",_dt_common.txt_color.SUCCESS,"][DataTable] Created collection '",collection_name,"' with success!")
	
	%label_collection.set_text(str("Opened collection: ", collection_name))
	%label_collection.set_tooltip_text(str("path: ",collection_path))
	
	_dt_backup.get_instance().make(collection_path)
	
	_dt_backup.get_instance().link(%backup_timer, collection_path)
	
	_new_file_dialog.queue_free()

func _on_close_load():
	_load_file_dialog.queue_free()

func _on_close_new():
	_new_file_dialog.queue_free()
