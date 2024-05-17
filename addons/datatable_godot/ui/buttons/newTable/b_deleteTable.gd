@tool
extends Button

@onready var bg_newTable: Panel = $"../../../../../../.."

func _pressed():
	bg_newTable.delete_table.emit(get_parent())
