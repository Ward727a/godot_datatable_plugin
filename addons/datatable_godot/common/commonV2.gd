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

const SIZE_SINGLE = 0
const SIZE_ARRAY = 1
const SIZE_MAX = 2

const INT_ICON = "res://addons/datatable_godot/icons/int.svg"
const FLOAT_ICON = "res://addons/datatable_godot/icons/float.svg"
const STR_ICON = "res://addons/datatable_godot/icons/String.svg"
const COLOR_ICON = "res://addons/datatable_godot/icons/Color.svg"
const V2_ICON = "res://addons/datatable_godot/icons/Vector2.svg"
const V3_ICON = "res://addons/datatable_godot/icons/Vector3.svg"
const V4_ICON = "res://addons/datatable_godot/icons/Vector4.svg"
const BOOL_ICON = "res://addons/datatable_godot/icons/bool.png"
const RESS_ICON = "res://addons/datatable_godot/icons/Ressource.png"
const QUAT_ICON = "res://addons/datatable_godot/icons/Quaternion.png"
const RECT_ICON = "res://addons/datatable_godot/icons/Rect2.png"
const PLANE_ICON = "res://addons/datatable_godot/icons/Plane.png"
const T2_ICON = "res://addons/datatable_godot/icons/Transform2D.png"
const T3_ICON = "res://addons/datatable_godot/icons/Transform3D.png"
const AABB_ICON = "res://addons/datatable_godot/icons/AABB.png"
const BASIS_ICON = "res://addons/datatable_godot/icons/Basis.png"
const PROJ_ICON = "res://addons/datatable_godot/icons/Projection.png"

const ARR_ICON = "res://addons/datatable_godot/icons/array_value.png"
const SINGLE_ICON = "res://addons/datatable_godot/icons/single_value.png"

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

func DEBUG(message: String):
	if _dt_plugin.get_instance().get_dev_debug() == "true":
		print_rich(str("[DataTable - Debug] ", message))

