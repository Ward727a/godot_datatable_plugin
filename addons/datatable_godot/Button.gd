@tool
extends Button

signal dropped_file_on(path: String)

func _can_drop_data(position, data):
	
	return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(position, data):
	
	dropped_file_on.emit(data['files'][0])
