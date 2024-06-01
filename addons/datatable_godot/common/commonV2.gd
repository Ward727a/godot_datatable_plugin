@tool
class_name _dt_common
## Class created by DataTable Plugin
## This class is used for common function that is used in multiple part of the plugin, like [method get_version], [method add_root], etc

# Color for text

const txt_color = {
	SUCCESS = "lightgreen",
	WARNING = "ffde66",
	ERROR = "ff768b",
	VECX = "fab293",
	VECY = "93fab2",
	VECZ = "b293fa",
	VECW = "93dbfa"
}

# Type for plugin

const TYPE_STRING = 0
const TYPE_INT = 1
const TYPE_FLOAT = 2
const TYPE_COLOR = 3
const TYPE_VECTOR2 = 4
const TYPE_VECTOR3 = 5
const TYPE_VECTOR4 = 6
const TYPE_BOOL = 7
const TYPE_RESS = 8 # Ressource
const TYPE_QUAT = 9 # Quaternion
const TYPE_RECT = 10
const TYPE_PLANE = 11
const TYPE_T2 = 12 # Transform2D
const TYPE_T3 = 13 # Transform3D
const TYPE_AABB = 14
const TYPE_BASIS = 15
const TYPE_PROJ = 16
const TYPE_MAX = 17

# backend func

func ASSERT_ERROR(message: String):
	assert(false, message)

func add_root(Child: Node):
	
	if Child == null || !Child:
		ASSERT_ERROR("Can't add child to EditorInterface: child null or invalid")
		return
	
	EditorInterface.get_base_control().add_child(Child)

func SUCCESS(message: String):
	print_rich(str("[color=",txt_color.SUCCESS,"][DataTable] ", message))

func WARNING(message: String):
	push_warning(str("[DataTable] ", message))

func ERROR(message: String):
	push_error(str("[DataTable] ", message))
