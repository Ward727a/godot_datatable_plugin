@tool
extends _dt_common
class_name _dt_classDB

# Created this because the default ClassDB doesn't detect custom created class

static func class_exist(className: String) -> bool:
	
	var arr = ProjectSettings.get_global_class_list().filter(
		func(data: Dictionary):
			return data['class'] == className
	)
	
	if arr.size() != 0:
		return true
	
	push_error(str("Class '",className,"' doesn't exist!"))
	return false

static func get_class_data(className: String) -> Dictionary:
	
	if !class_exist(className):
		return {}
	
	var arr = ProjectSettings.get_global_class_list().filter(
		func(data: Dictionary):
			return data['class'] == className
	)
	
	if arr.size() != 1:
		push_error(str("Found Multiple?? class with name '",className,"'!"))
		return {}
	
	return arr[0]

static func class_instantiate(className: String) -> Resource:
	
	if !class_exist(className):
		return null
	
	var classData = get_class_data(className)
	
	if classData == {}:
		return null
	
	if !classData.has('path'):
		push_error(str("Can't found key 'path' in class '",className,"'!"))
		return null
	
	if !classData.has('language'):
		push_error(str("Can't found key 'language' in class '",className,"'!"))
		return null
	
	if classData['language'] != 'GDScript':
		push_error(str("The class '",className,"' isn't a GDScript class!"))
		return null
	
	var script: GDScript = load(classData['path'])
	
	return script
