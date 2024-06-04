@tool
extends ConfirmationDialog

var codeNode: CodeEdit
var file_dialog: FileDialog

var className: String = "":
	set(new_value):
		className = new_value
		set_title(str("Generated Class Preview: ", className))

var content: String = "":
	set(new_value):
		content = new_value
		codeNode.set_text(content)

func _ready():
	codeNode = get_child(0).get_child(0)
	
	codeNode.set_language('GDScript')
	
	get_ok_button().pressed.connect(_on_save_file_asked)

func _on_save_file_asked():
	
	file_dialog = FileDialog.new()
	
	file_dialog.add_filter("*.gd", "GDScript")
	
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	file_dialog.file_selected.connect(_on_save_file)
	file_dialog.canceled.connect(_on_cancel_save)
	
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	file_dialog.size = Vector2(300, 400)
	
	EditorInterface.get_base_control().add_child(file_dialog)
	
	file_dialog.visible = true
	
	return

func _on_save_file(path: String):
	
	var script_file: GDScript = GDScript.new()
	
	script_file.set_source_code(content)
	
	ResourceSaver.save(script_file, path)
	
	EditorInterface.get_file_system_dock().navigate_to_path(path)

func _on_cancel_save():
	file_dialog.visible = false
	file_dialog.queue_free()
