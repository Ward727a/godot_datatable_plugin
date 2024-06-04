@tool
extends RichTextLabel

@onready var bg: Panel = $"../../../../../../../../.."

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var object_node: HBoxContainer = get_parent()
			
			bg.select_type.emit(object_node)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var object_node: HBoxContainer = get_parent()
			bg.generate_class.emit(object_node)
