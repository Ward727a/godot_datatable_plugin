@tool
extends LineEdit

@onready var bg_manageType: Panel = $"../../../../../../.."
@onready var b_add_param: Button = $"../b_add_param"

# Called when the node enters the scene tree for the first time.
func _ready():
	text_changed.connect(_signal_text_edited)
	text_submitted.connect(_signal_submit)
	bg_manageType.edit_param_name_response.connect(_signal_text_valid)
	bg_manageType.recheck_param_name.connect(_recheck_valid)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _signal_text_edited(new_value: String):
	bg_manageType.edit_param_name_ask.emit(new_value)

func _signal_text_valid(valid: bool):
	if valid:
		add_theme_color_override("font_color", Color(1,1,1,1))
		b_add_param.disabled = false
	else:
		add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))
		b_add_param.disabled = true

func _recheck_valid():
	bg_manageType.edit_param_name_ask.emit(get_text())

func _signal_submit(_text_value: String):
	b_add_param._pressed()
