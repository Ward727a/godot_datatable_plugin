@tool
extends Button


@onready var bg: Panel = $"../../../../../../../../.."

func _pressed():
	bg.remove_type.emit(get_parent())
