@tool
extends Button

@onready var bg_newTable: Panel = $"../../../../../.."
@onready var item_name: LineEdit = $"../in_itemTableName"

func _pressed():
	if disabled:
		return
	bg_newTable.create_item.emit(item_name.get_text())
