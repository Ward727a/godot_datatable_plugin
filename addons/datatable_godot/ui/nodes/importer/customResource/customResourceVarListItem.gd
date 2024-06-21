@tool
extends HBoxContainer

signal var_import_changed(var_name: String, var_import: bool, var_type: String)

@onready var _varName: Label = %varName
@onready var _varType: Label = %varType
@onready var _varImport: CheckBox = %varImport

var var_name = "":
	set(new_value):
		var_name = new_value
		%varName.set_text(new_value)

var var_type = "":
	set(new_value):
		var_type = new_value
		%varType.set_text(type_string(new_value.to_int()).capitalize())

var var_valid: bool = true:
	set(new_value):
		var_valid = new_value
		if new_value:
			%varName.remove_theme_color_override("font_color")
			%varName.tooltip_text = ""
		else:
			print("Invalid var name: ", var_name)
			%varName.add_theme_color_override("font_color", Color(1, .47, .42))
			%varName.tooltip_text = "This name is not present in the used structure. If you import it, it will be added to the structure."

var var_import = false

func _ready():
	_varImport.pressed.connect(_on_varImport_pressed)

func _on_varImport_pressed():
	var_import = _varImport.button_pressed
	var_import_changed.emit(var_name, var_import, var_type)

func _on_deselect(except_name: String):
	if except_name != var_name:
		_varImport.button_pressed = false
		var_import = false
		var_import_changed.emit(var_name, var_import, var_type)

func _on_block(except_name: String):
	if except_name != var_name:
		_varImport.disabled = true

func _on_unblock():
	_varImport.disabled = false