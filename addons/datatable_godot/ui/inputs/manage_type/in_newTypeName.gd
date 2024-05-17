@tool
extends LineEdit

@onready var bg_manageType: Panel = $"../../../../.."
@onready var b_addType: Button = $"../b_addType"

func _ready():
	
	text_changed.connect(_text_change)
	text_submitted.connect(_signal_submit)
	bg_manageType.check_type_name_response.connect(_check_name)
	bg_manageType.recheck_type_name.connect(_recheck_validity)
	

func _text_change(new_value: String):
	bg_manageType.check_type_name_ask.emit(new_value)

func _check_name(valid: bool):
	if valid:
		add_theme_color_override("font_color", Color(1,1,1,1))
		b_addType.disabled = false
	else:
		add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))
		b_addType.disabled = true

func _recheck_validity():
	bg_manageType.check_type_name_ask.emit(get_text())

func _signal_submit(_text_value: String):
	b_addType._pressed()
