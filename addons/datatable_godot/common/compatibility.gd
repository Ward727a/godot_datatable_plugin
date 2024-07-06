@tool
class_name _dt_compatibility
extends _dt_common


static var _INSTANCE: _dt_compatibility

static func delete():
	_INSTANCE = null

static func get_instance() -> _dt_compatibility:
	
	if !_INSTANCE || _dt_plugin.get_instance().get_dev_reset_instance() == "true":
		_INSTANCE = _dt_compatibility.new()
	
	return _INSTANCE


# Global check for the compatibility with the actually installed version of the DataTable

func check_file_version(version_file: String) -> bool:

	var file_version_plugin: String = _dt_plugin.get_instance().get_file_version()

	var file_version_plugin_conv = _dt_plugin.get_instance().version_to_number(file_version_plugin)
	var version_file_conv = _dt_plugin.get_instance().version_to_number(version_file)

	# We compare the version of the file with the version of the plugin, if the version of the file is higher or equal than the version of the plugin, we return true
	if version_file_conv >= file_version_plugin_conv:
		DEBUG(str("The version of the file is higher or equal than the version of the plugin (", version_file, " >= ", file_version_plugin, ")"))
		return true
	
	DEBUG(str("The version of the file is lower than the version of the plugin (", version_file, " < ", file_version_plugin, ")"))
	return false

func check_compatibility(_data: Dictionary) -> void:

	if _data == {}:
		ERROR("The data is empty, the compatibility check can't continue!")
		return
	
	var force_conversion: bool = false

	if !_data.has("meta"):
		force_conversion = true
		_data['meta'] = {"version": "1.0.0"}
	
	var meta = _data['meta']

	if !meta.has("version"):
		force_conversion = true
		meta['version'] = "1.0.0"
	
	if force_conversion or !check_file_version(meta['version']):

		if _dt_plugin.get_instance().get_dev_stop_convert() == "true":
			WARNING("The data is not compatible with the installed version of the DataTable, but the dev config 'stop_convert' is on true!")
			WARNING("The data will not be converted!")
			WARNING("---------------------------------")
			return

		WARNING(str("The data is not compatible with the installed version of the DataTable (", _dt_plugin.get_instance().get_version(), ")"))
		WARNING("The plugin will try to convert your data to the new format")
		WARNING("Please, don't stop the process and wait for the conversion to finish, or else you could lose your data!")
		WARNING("---------------------------------")
		WARNING("The conversion process can take a while depending on the amount of data to convert")
		WARNING("---------------------------------")
		WARNING("Creating a backup of the data before the conversion...")

		var collection_path = _dt_resource.get_instance().get_path()

		WARNING(str("\tPath of the collection to backup: ", collection_path))
		WARNING("---------------------------------")

		var is_backup_success: bool = _dt_backup.get_instance().manual_backup(collection_path, "pre_conversion_backup_%name%")
		
		if !is_backup_success:

			if _dt_plugin.get_instance().get_dev_force_convert() == "true":
				WARNING("The backup process failed, but the conversion will continue because the dev config 'force_convert' is on true!")
				WARNING("---------------------------------")
			else:
				ERROR("The backup process failed, the conversion will stop by security!")
				WARNING("---------------------------------")
				return
		else:
			WARNING("The backup process was successful, the conversion will continue!")
			WARNING("---------------------------------")
		
		WARNING("Starting the conversion process...")
		WARNING("---------------------------------")

		WARNING(">> Loading the data...")

		var data_to_convert = _dt_resource.get_instance().load_file(collection_path)

		if data_to_convert == null:
			ERROR("The data to convert is null, the conversion will stop!")
			WARNING("---------------------------------")
			return
		
		if !data_to_convert.has("table"):
			ERROR("The data to convert doesn't have the 'table' key, the conversion can't continue!")
			WARNING("---------------------------------")
			return
		
		WARNING(">> Data loaded successfully!")

		WARNING(">> The editor can freeze during the conversion, don't worry, it's normal!")
		
		var watch_dog_limit: int = int(_dt_plugin.get_instance().get_dev_convert_watchdog_limit())
		var watch_dog: int = 0

		WARNING(str(">> Watchdog limit: ", watch_dog_limit, " | If the conversion takes more than this limit, the process will stop!"))

		if !data_to_convert.has('table'):
			ERROR("The data doesn't have the key 'table', the conversion can't continue!")
			ERROR("---------------------------------")
			return
		
		var tables = data_to_convert['table']

		for key in tables:

			var table = tables[key]

			watch_dog += 1
			if watch_dog > watch_dog_limit:
				ERROR(">> Watchdog limit reached, the process will stop!")
				ERROR("---------------------------------")
				ERROR("The conversion process took too long, the process will stop!")
				ERROR("If you know what you're doing, you can increase the limit in the dev config!")
				ERROR("---------------------------------")
				return
			
			DEBUG(str(">> Checking if the data has the key: rows"))

			if !table.has("rows"):
				ERROR(str(">> The data doesn't have the key 'rows', the conversion can't continue!"))
				ERROR("---------------------------------")
				return
			
			var rows = table['rows']

			DEBUG(str(">> Converting table: ", key))
			
			for row_key in rows:
				watch_dog += 1
				if watch_dog > watch_dog_limit:
					ERROR(">> Watchdog limit reached, the process will stop!")
					ERROR("---------------------------------")
					ERROR("The conversion process took too long, the process will stop!")
					ERROR("If you know what you're doing, you can increase the limit in the dev config!")
					ERROR("---------------------------------")
					return
				var row = rows[row_key]

				DEBUG(str(">> Converting row: ", row_key))

				for column_key in row['columns']:
					watch_dog += 1
					if watch_dog > watch_dog_limit:
						ERROR(">> Watchdog limit reached, the process will stop!")
						ERROR("---------------------------------")
						ERROR("The conversion process took too long, the process will stop!")
						ERROR("If you know what you're doing, you can increase the limit in the dev config!")
						ERROR("---------------------------------")
						return
					var column = row['columns'][column_key]

					DEBUG(str(">> Converting column: ", column_key))

					DEBUG(str(">> Checking if the column has the key 'type' & 'value"))

					if !column.has("value"):
						ERROR(str(">> The column doesn't have the key 'value', the conversion can't continue!"))
						ERROR("---------------------------------")
						return
					
					if !column.has("type"):
						ERROR(str(">> The column doesn't have the key 'type', the conversion can't continue!"))
						ERROR("---------------------------------")
						return

					var value = column['value']
					var type = column['type']

					DEBUG(str(">> Checking if the column need to be converted"))

					if !check_need_reformat_v230(value):
						DEBUG(str(">> The column doesn't need to be converted"))
						continue

					match type:
						self.TYPE_BASIS:
							DEBUG(str(">> Converting basis to the new format"))
							var new_value = convert_basis_to_v230(value)
							column['value'] = new_value
						self.TYPE_PROJ:
							DEBUG(str(">> Converting projection to the new format"))
							var new_value = convert_projection_to_v230(value)
							column['value'] = new_value
						self.TYPE_AABB:
							DEBUG(str(">> Converting aabb to the new format"))
							var new_value = convert_aabb_to_v230(value)
							column['value'] = new_value
						self.TYPE_PLANE:
							DEBUG(str(">> Converting plane to the new format"))
							var new_value = convert_plane_to_v230(value)
							column['value'] = new_value
						self.TYPE_QUAT:
							DEBUG(str(">> Converting quaternion to the new format"))
							var new_value = convert_quaternion_to_v230(value)
							column['value'] = new_value
						self.TYPE_RECT:
							DEBUG(str(">> Converting rect to the new format"))
							var new_value = convert_rect_to_v230(value)
							column['value'] = new_value
						self.TYPE_T2:
							DEBUG(str(">> Converting transform2d to the new format"))
							var new_value = convert_transform2d_to_v230(value)
							column['value'] = new_value
						self.TYPE_T3:
							DEBUG(str(">> Converting transform3d to the new format"))
							var new_value = convert_transform3d_to_v230(value)
							column['value'] = new_value
						self.TYPE_VECTOR4:
							DEBUG(str(">> Converting vector4 to the new format"))
							var new_value = convert_v4_to_v230(value)
							column['value'] = new_value
						self.TYPE_COLOR:
							DEBUG(str(">> Converting color to the new format"))
							var new_value = convert_color_to_v230(value)
							column['value'] = new_value
						_:
							ERROR(str(">> The process has detected that the column need to be converted, but the type is not recognized!"))
							ERROR(str(">> The conversion can't continue!"))
							ERROR(str(">> Please, contact the developer to fix this issue! (type of the object: ", type, ")"))
							ERROR("---------------------------------")
							return

					DEBUG(str(">> Column converted successfully!"))
				
				DEBUG(str(">> Row converted successfully!"))
			
			DEBUG(str(">> Table converted successfully!"))

		WARNING(">> Conversion process finished successfully!")
		WARNING("---------------------------------")
		WARNING(str("The data has been converted to the new format (", _dt_plugin.get_instance().get_version(), ")"))
		WARNING("The plugin will now try to save the data to the file...")
		WARNING("---------------------------------")

		WARNING(">> Changing the meta data to the new file version...")

		data_to_convert['meta']['version'] = _dt_plugin.get_instance().get_file_version()

		WARNING(">> Saving the data to the file...")

		var is_save_success: bool = _dt_resource.get_instance().manualy_save_file(collection_path, data_to_convert)

		if !is_save_success:
			ERROR("The data couldn't be saved to the file, the process will stop!")
			ERROR("---------------------------------")
			return
		
		WARNING("The data has been saved successfully!")
		WARNING("---------------------------------")

		WARNING("Try to reload the data in the editor...")

		var is_data_loaded: Dictionary = _dt_resource.get_instance().force_load(collection_path)
		_dt_resource.get_instance().res_reload.emit()

		if is_data_loaded == null:
			ERROR("The data couldn't be reloaded in the editor, please try to reload the plugin in it's entirety!")
			ERROR("---------------------------------")
			return
		
		WARNING("The data has been reloaded successfully!")
		WARNING("---------------------------------")
		SUCCESS("---------------------------------")
		SUCCESS("The data has been converted and saved successfully!")
		SUCCESS("You can now use the DataTable as usual!")
		SUCCESS("---------------------------------")


# All conversion from the old format to the new format that appears in the DataTable 2.3.0

func invalid_format_v230(format: String) -> void:
	
	push_error(str("[DataTable] Invalid ", format, " format (maybe the version of the format is not < 2.3.0)"))

func check_need_reformat_v230(old_format: Variant) -> bool:
	
	if typeof(old_format) != Variant.Type.TYPE_STRING:
		return false

	if (
		old_format.begins_with("V4/") or 
		old_format.begins_with("AB/") or 
		old_format.begins_with("BS/") or 
		old_format.begins_with("C/") or
		old_format.begins_with("PL/") or
		old_format.begins_with("PJ/") or
		old_format.begins_with("QT/") or
		old_format.begins_with("RECT/") or
		old_format.begins_with("T2/") or
		old_format.begins_with("T3/")
		):
		return true
	
	return false

func convert_color_to_v230(old_color: String) -> String:
	
	if old_color.begins_with("C/"):
		var trimmed_color: String = old_color.replace("C/", "")

		var color_values: Array = trimmed_color.split(",")

		if color_values.size() != 4:
			invalid_format_v230("color")
			return old_color

		var r: float = float(color_values[0])
		var g: float = float(color_values[1])
		var b: float = float(color_values[2])
		var a: float = float(color_values[3])

		var color: Color = Color(r, g, b, a)

		var color_v230 = var_to_str(color)

		return color_v230
	
	invalid_format_v230("color")
	return old_color

func convert_v4_to_v230(old_v4: String) -> String:

	if old_v4.begins_with("V4/"):
		var trimmed_v4: String = old_v4.replace("V4/", "")

		var v4_values: Array = trimmed_v4.split(",")

		if v4_values.size() != 4:
			invalid_format_v230("vector4")
			return old_v4

		var x: float = float(v4_values[0])
		var y: float = float(v4_values[1])
		var z: float = float(v4_values[2])
		var w: float = float(v4_values[3])

		var v4: Vector4 = Vector4(x, y, z, w)

		var v4_v230 = var_to_str(v4)

		return v4_v230

	invalid_format_v230("vector4")
	return old_v4

func convert_aabb_to_v230(old_aabb: String) -> String:

	if old_aabb.begins_with("AB/"):
		var trimmed_aabb: String = old_aabb.replace("AB/", "")

		var aabb_values: Array = trimmed_aabb.split(",")

		if aabb_values.size() != 6:
			invalid_format_v230("aabb")
			return old_aabb

		var x: float = float(aabb_values[0])
		var y: float = float(aabb_values[1])
		var z: float = float(aabb_values[2])
		var w: float = float(aabb_values[3])
		var h: float = float(aabb_values[4])
		var d: float = float(aabb_values[5])

		var aabb: AABB = AABB(Vector3(x, y, z), Vector3(w, h, d))

		var aabb_v230 = var_to_str(aabb)

		return aabb_v230

	invalid_format_v230("aabb")
	return old_aabb

func convert_basis_to_v230(old_basis: String) -> String:

	if old_basis.begins_with("BS/"):
		var trimmed_basis: String = old_basis.replace("BS/", "")

		var basis_values: Array = trimmed_basis.split(",")

		if basis_values.size() != 9:
			invalid_format_v230("basis")
			return old_basis

		var vx: Vector3 = Vector3(float(basis_values[0]), float(basis_values[1]), float(basis_values[2]))
		var vy: Vector3 = Vector3(float(basis_values[3]), float(basis_values[4]), float(basis_values[5]))
		var vz: Vector3 = Vector3(float(basis_values[6]), float(basis_values[7]), float(basis_values[8]))

		var basis: Basis = Basis(vx, vy, vz)

		var basis_v230 = var_to_str(basis)

		return basis_v230

	invalid_format_v230("basis")
	return old_basis

func convert_plane_to_v230(old_plane: String) -> String:

	if old_plane.begins_with("PL/"):
		var trimmed_plane: String = old_plane.replace("PL/", "")

		var plane_values: Array = trimmed_plane.split(",")

		if plane_values.size() != 4:
			invalid_format_v230("plane")
			return old_plane

		var x: float = float(plane_values[0])
		var y: float = float(plane_values[1])
		var z: float = float(plane_values[2])
		var d: float = float(plane_values[3])

		var plane: Plane = Plane(x, y, z, d)

		var plane_v230 = var_to_str(plane)

		return plane_v230

	invalid_format_v230("plane")
	return old_plane

func convert_projection_to_v230(old_projection: String) -> String:

	if old_projection.begins_with("PJ/"):
		var trimmed_projection: String = old_projection.replace("PJ/", "")

		var projection_values: Array = trimmed_projection.split(",")

		if projection_values.size() != 16:
			invalid_format_v230("projection")
			return old_projection

		var x: float = float(projection_values[0])
		var y: float = float(projection_values[1])
		var z: float = float(projection_values[2])
		var d: float = float(projection_values[3])
		var e: float = float(projection_values[4])
		var f: float = float(projection_values[5])
		var g: float = float(projection_values[6])
		var h: float = float(projection_values[7])
		var i: float = float(projection_values[8])
		var j: float = float(projection_values[9])
		var k: float = float(projection_values[10])
		var l: float = float(projection_values[11])
		var m: float = float(projection_values[12])
		var n: float = float(projection_values[13])
		var o: float = float(projection_values[14])
		var p: float = float(projection_values[15])

		var projection: Projection = Projection(
			Vector4(x, y, z, d),
			Vector4(e, f, g, h),
			Vector4(i, j, k, l),
			Vector4(m, n, o, p)
		)

		var projection_v230 = var_to_str(projection)

		return projection_v230

	invalid_format_v230("projection")
	return old_projection

func convert_quaternion_to_v230(old_quaternion: String) -> String:

	if old_quaternion.begins_with("QT/"):
		var trimmed_quaternion: String = old_quaternion.replace("QT/", "")

		var quaternion_values: Array = trimmed_quaternion.split(",")

		if quaternion_values.size() != 4:
			invalid_format_v230("quaternion")
			return old_quaternion

		var x: float = float(quaternion_values[0])
		var y: float = float(quaternion_values[1])
		var z: float = float(quaternion_values[2])
		var w: float = float(quaternion_values[3])

		var quaternion: Quaternion = Quaternion(x, y, z, w)

		var quaternion_v230 = var_to_str(quaternion)

		return quaternion_v230

	invalid_format_v230("quaternion")
	return old_quaternion

func convert_rect_to_v230(old_rect: String) -> String:

	if old_rect.begins_with("RECT/"):
		var trimmed_rect: String = old_rect.replace("RECT/", "")

		var rect_values: Array = trimmed_rect.split(",")

		if rect_values.size() != 4:
			invalid_format_v230("rect")
			return old_rect

		var x: float = float(rect_values[0])
		var y: float = float(rect_values[1])
		var w: float = float(rect_values[2])
		var h: float = float(rect_values[3])

		var rect: Rect2 = Rect2(x, y, w, h)

		var rect_v230 = var_to_str(rect)

		return rect_v230

	invalid_format_v230("rect")
	return old_rect

func convert_transform2d_to_v230(old_transform2d: String) -> String:

	if old_transform2d.begins_with("T2/"):
		var trimmed_transform2d: String = old_transform2d.replace("T2/", "")

		var transform2d_values: Array = trimmed_transform2d.split(",")

		if transform2d_values.size() != 6:
			invalid_format_v230("transform2d")
			return old_transform2d

		var x: float = float(transform2d_values[0])
		var y: float = float(transform2d_values[1])
		var xx: float = float(transform2d_values[2])
		var yx: float = float(transform2d_values[3])
		var xy: float = float(transform2d_values[4])
		var yy: float = float(transform2d_values[5])

		var transform2d: Transform2D = Transform2D(Vector2(x, y), Vector2(xx, yx), Vector2(xy, yy))

		var transform2d_v230 = var_to_str(transform2d)

		return transform2d_v230

	invalid_format_v230("transform2d")
	return old_transform2d

func convert_transform3d_to_v230(old_transform3d: String) -> String:

	if old_transform3d.begins_with("T3/"):
		var trimmed_transform3d: String = old_transform3d.replace("T3/", "")

		var transform3d_values: Array = trimmed_transform3d.split(",")

		if transform3d_values.size() != 12:
			invalid_format_v230("transform3d")
			return old_transform3d

		var x: float = float(transform3d_values[0])
		var y: float = float(transform3d_values[1])
		var z: float = float(transform3d_values[2])
		var xx: float = float(transform3d_values[3])
		var yx: float = float(transform3d_values[4])
		var zx: float = float(transform3d_values[5])
		var xy: float = float(transform3d_values[6])
		var yy: float = float(transform3d_values[7])
		var zy: float = float(transform3d_values[8])
		var xz: float = float(transform3d_values[9])
		var yz: float = float(transform3d_values[10])
		var zz: float = float(transform3d_values[11])

		var transform3d: Transform3D = Transform3D(
			Vector3(x, y, z),
			Vector3(xx, yx, zx),
			Vector3(xy, yy, zy),
			Vector3(xz, yz, zz)
		)

		var transform3d_v230 = var_to_str(transform3d)

		return transform3d_v230

	invalid_format_v230("transform3d")
	return old_transform3d