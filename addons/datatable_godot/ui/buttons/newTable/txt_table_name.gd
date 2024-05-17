@tool
extends RichTextLabel

@onready var bg_newTable: Panel = $"../../../../../../.."

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			bg_newTable.select_table.emit(get_parent())
