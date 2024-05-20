@tool
extends Button

@onready var bg_manageType: Panel = $"../../../../../../.."

@onready var in_new_param_name: LineEdit = $"../in_new_param_name"
@onready var ob_param_type: OptionButton = $"../OB_paramType"
@onready var ob_param_size: OptionButton = $"../OB_paramSize"

func _ready():
	bg_manageType.add_param_response.connect(_add_response)

func _pressed():
	
	var paramType: int = ob_param_type.get_selected_id()
	var paramSize: int = ob_param_size.get_selected_id()
	var paramName: String = in_new_param_name.get_text()
	
	if paramName.is_empty():
		return
	
	bg_manageType.add_param_ask.emit(paramName, paramType, paramSize)

func _add_response(success: bool):
	
	if success:
		in_new_param_name.set_text("")
	
