@tool
extends LineEdit

@onready var common: Node = %signals
@onready var bg_newTable: Panel = $"../../../../.."
@onready var b_createTable: Button = $"../b_createTable"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	text_changed.connect(_signal_text_change)
	text_submitted.connect(_signal_submit)
	bg_newTable.add_table_response.connect(_signal_add_table_response)
	
	pass # Replace with function body.

func _signal_text_change(new_value: String):
	if bg_newTable.scan_table_name(new_value):
		add_theme_color_override("font_color", Color(1,1,1,1))
	else:
		add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))

func _signal_add_table_response():
	set_text("")

func _signal_submit(_text_value: String):
	b_createTable._pressed()
