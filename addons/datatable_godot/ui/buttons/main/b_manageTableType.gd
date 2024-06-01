@tool
extends Button

## import common node to access signals
@onready var common: Node = %signals

func _pressed():
	_dt_interface.get_instance().show_type()

