@tool
extends Button

@onready var bg_manageType: Panel = $"../../../../.."
@onready var in_type_name: LineEdit = $"../in_newTypeName"

func _ready():
	bg_manageType.add_type_response.connect(_is_added)

func _pressed():
	bg_manageType.add_type_ask.emit(in_type_name.get_text())

func _is_added(success: bool):
	
	if success:
		in_type_name.set_text("")
