@tool
extends _dt_common
class_name _dt_schema

var string_schema: Resource
var int_schema: Resource
var float_schema: Resource
var color_schema: Resource
var vector2_schema: Resource
var vector3_schema: Resource
var vector4_schema: Resource
var t2_schema: Resource
var t3_schema: Resource
var array_schema: Resource
var bool_schema: Resource
var ress_schema: Resource
var quat_schema: Resource
var plane_schema: Resource
var rect_schema: Resource
var aabb_schema: Resource
var basis_schema: Resource
var proj_schema: Resource

var custom_schema: Dictionary

static var _INSTANCE: _dt_schema

static func delete():
	_INSTANCE = null

static func get_instance() -> _dt_schema:
	
	if !_INSTANCE:
		_INSTANCE = _dt_schema.new()
		_INSTANCE.load_var()
	
	return _INSTANCE

func load_var():
	string_schema = preload("res://addons/datatable_godot/ui/nodes/schema/string_schema.tscn")
	int_schema = preload("res://addons/datatable_godot/ui/nodes/schema/int_schema.tscn")
	float_schema = preload("res://addons/datatable_godot/ui/nodes/schema/float_schema.tscn")
	color_schema = preload("res://addons/datatable_godot/ui/nodes/schema/color_schema.tscn")
	vector2_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_2_schema.tscn")
	vector3_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_3_schema.tscn")
	vector4_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_4_schema.tscn")
	t2_schema = preload("res://addons/datatable_godot/ui/nodes/schema/t_2_schema.tscn")
	t3_schema = preload("res://addons/datatable_godot/ui/nodes/schema/t_3_schema.tscn")
	array_schema = preload("res://addons/datatable_godot/ui/nodes/schema/array_schema.tscn")
	bool_schema = preload("res://addons/datatable_godot/ui/nodes/schema/bool_schema.tscn")
	ress_schema = preload("res://addons/datatable_godot/ui/nodes/schema/ress_schema.tscn")
	quat_schema = preload("res://addons/datatable_godot/ui/nodes/schema/quat_schema.tscn")
	plane_schema = preload("res://addons/datatable_godot/ui/nodes/schema/plane_schema.tscn")
	rect_schema = preload("res://addons/datatable_godot/ui/nodes/schema/rect_schema.tscn")
	aabb_schema = preload("res://addons/datatable_godot/ui/nodes/schema/aabb_schema.tscn")
	basis_schema = preload("res://addons/datatable_godot/ui/nodes/schema/basis_schema.tscn")
	proj_schema = preload("res://addons/datatable_godot/ui/nodes/schema/proj_schema.tscn")

func each() -> Array:
	return [
		string_schema,
		int_schema,
		float_schema,
		color_schema,
		vector2_schema,
		vector3_schema,
		vector4_schema,
		t2_schema,
		t3_schema,
		array_schema,
		bool_schema,
		ress_schema,
		quat_schema,
		plane_schema,
		rect_schema,
		aabb_schema,
		basis_schema,
		proj_schema
	]

func add_custom(schema_name: String, schema_path: String) -> bool:
	
	if custom_schema.has(schema_name):
		ERROR("Can't add a schema with the same name as another one")
		return false
	
	custom_schema[schema_name] = load(schema_path)
	
	return true
