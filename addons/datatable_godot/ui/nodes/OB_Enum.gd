@tool
extends OptionButton

# This script is still in WIP

var enum_ = []

func _reload():
	
	clear()
	
	for item in enum_:
		var enum_name = item['name']
		var enum_id = item['id']
		var enum_icon = item['icon']
		
		add_item(enum_name, enum_id)
		set_item_icon(enum_id, enum_icon)

func add_enum(enum_name: String, enum_icon: Texture2D = null):
	
	enum_.append({"name": enum_name, "id": enum_.size(), "icon": enum_icon})

func clear_enum():
	
	enum_.clear()

func set_enum(enum_id: int, enum_name: String, enum_icon: Texture2D = null):
	
	enum_[enum_id] = {"name": enum_name, "id": enum_id, "icon": enum_icon}

func get_enum(id: int):
	
	return enum_[id]

func get_all_enum():
	
	return enum_
