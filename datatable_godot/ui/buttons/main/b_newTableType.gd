@tool
extends Button

## import common node to access signals
@onready var common: Node = %signals

func _pressed():
	common.toggle_newType_ask.emit()
