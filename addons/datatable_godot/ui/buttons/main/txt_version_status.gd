@tool
extends RichTextLabel

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_dt_updater.get_instance().check_update(self)
