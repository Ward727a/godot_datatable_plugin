@tool
extends LineEdit

@onready var common: Node = %signals
@onready var bg_newTable: Panel = $"../../../../../.."
@onready var b_addItem: Button = $"../b_addItemTable"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	text_changed.connect(_signal_text_change)
	text_submitted.connect(_signal_submit)
	bg_newTable.create_item_response.connect(_signal_add_item_response)
	bg_newTable.delete_item_response.connect(_signal_remove_item_response)
	bg_newTable.reload_item_list.connect(_signal_reload)
	
	pass # Replace with function body.

func _signal_text_change(new_value: String):
	if bg_newTable.scan_item_name(new_value):
		add_theme_color_override("font_color", Color(1,1,1,1))
		if !b_addItem.get_meta('force_disabled'):
			b_addItem.disabled = false
	else:
		add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))
		if !b_addItem.get_meta('force_disabled'):
			b_addItem.disabled = true

func _signal_add_item_response(success: bool):
	if success:
		set_text("")

func _signal_remove_item_response(success: bool):
	if success:
		_signal_text_change(get_text())

func _signal_submit(_text_value: String):
	b_addItem._pressed()

func _signal_reload():
	_signal_text_change(get_text())
