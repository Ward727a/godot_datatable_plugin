@tool
extends Button

@onready var bg_manageType: Panel = $"../../../../../../../../../../../.."


func _pressed():
	bg_manageType.remove_param_ask.emit(get_meta('param_name'))
	
	get_parent().queue_free()
