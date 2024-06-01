@tool
extends _dt_common
class_name _dt_schema

var string_schema: Node
var int_schema: Node
var float_schema: Node
var color_schema: Node
var vector2_schema: Node
var vector3_schema: Node
var vector4_schema: Node
var t2_schema: Node
var t3_schema: Node
var array_schema: Node
var bool_schema: Node
var ress_schema: Node
var quat_schema: Node
var plane_schema: Node
var rect_schema: Node
var aabb_schema: Node
var basis_schema: Node
var proj_schema: Node

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
	string_schema = preload("res://addons/datatable_godot/ui/nodes/schema/string_schema.tscn").instantiate()
	int_schema = preload("res://addons/datatable_godot/ui/nodes/schema/int_schema.tscn").instantiate()
	float_schema = preload("res://addons/datatable_godot/ui/nodes/schema/float_schema.tscn").instantiate()
	color_schema = preload("res://addons/datatable_godot/ui/nodes/schema/color_schema.tscn").instantiate()
	vector2_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_2_schema.tscn").instantiate()
	vector3_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_3_schema.tscn").instantiate()
	vector4_schema = preload("res://addons/datatable_godot/ui/nodes/schema/vector_4_schema.tscn").instantiate()
	t2_schema = preload("res://addons/datatable_godot/ui/nodes/schema/t_2_schema.tscn").instantiate()
	t3_schema = preload("res://addons/datatable_godot/ui/nodes/schema/t_3_schema.tscn").instantiate()
	array_schema = preload("res://addons/datatable_godot/ui/nodes/schema/array_schema.tscn").instantiate()
	bool_schema = preload("res://addons/datatable_godot/ui/nodes/schema/bool_schema.tscn").instantiate()
	ress_schema = preload("res://addons/datatable_godot/ui/nodes/schema/ress_schema.tscn").instantiate()
	quat_schema = preload("res://addons/datatable_godot/ui/nodes/schema/quat_schema.tscn").instantiate()
	plane_schema = preload("res://addons/datatable_godot/ui/nodes/schema/plane_schema.tscn").instantiate()
	rect_schema = preload("res://addons/datatable_godot/ui/nodes/schema/rect_schema.tscn").instantiate()
	aabb_schema = preload("res://addons/datatable_godot/ui/nodes/schema/aabb_schema.tscn").instantiate()
	basis_schema = preload("res://addons/datatable_godot/ui/nodes/schema/basis_schema.tscn").instantiate()
	proj_schema = preload("res://addons/datatable_godot/ui/nodes/schema/proj_schema.tscn").instantiate()

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
	
	custom_schema[schema_name] = load(schema_path).instantiate()
	
	return true
