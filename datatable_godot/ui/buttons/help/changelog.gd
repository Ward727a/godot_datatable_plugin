@tool
extends Button


@onready var about:ScrollContainer = $"../../../HBoxContainer/left_menu_box/MarginContainer/about"
@onready var changelog:ScrollContainer = $"../../../HBoxContainer/left_menu_box/MarginContainer/changelog"

func _pressed():
	about.visible = false
	changelog.visible = true
