@tool
extends HBoxContainer

@onready var text: Node

func _ready():
	text = get_child(0)

func select(toggle: bool):
	
	if text == null:
		return
	
	if toggle:
		text.add_theme_color_override("default_color", get_theme_color("accent_color", "Editor"))
	else:
		text.remove_theme_color_override("default_color")
