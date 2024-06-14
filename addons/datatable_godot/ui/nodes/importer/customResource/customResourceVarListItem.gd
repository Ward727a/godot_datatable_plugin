@tool
extends HBoxContainer

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

var var_import = false

func _ready():
	_varImport.pressed.connect(_on_varImport_pressed)

func _on_varImport_pressed():
	var_import = _varImport.pressed