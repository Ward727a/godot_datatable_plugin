@tool
extends Button

@onready var bg_newTable: Panel = $"../../../../.."
@onready var in_tableTitle: LineEdit = $"../in_tableTitle"

func _ready():
	bg_newTable.create_table_response.connect(_reset_input)

func _pressed():
	if disabled:
		return
	bg_newTable.create_table.emit(in_tableTitle.get_text())

func _reset_input(success: bool):
	if success:
		in_tableTitle.set_text("")
