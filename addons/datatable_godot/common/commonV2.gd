@tool
class_name _dt_common
## Class created by DataTable Plugin
## This class is used for common function that is used in multiple part of the plugin, like [method get_version], [method add_root], etc

# backend func

func ASSERT_ERROR(message: String):
	assert(false, message)

func add_root(Child: Node):
	
	if Child == null || !Child:
		ASSERT_ERROR("Can't add child to EditorInterface: child null or invalid")
		return
	
	EditorInterface.get_base_control().add_child(Child)

